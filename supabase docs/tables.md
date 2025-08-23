<!-- @format -->

-- =========================================
-- InterUFMT – Esquema mínimo (ordem corrigida)
-- =========================================

-- Extensões e Tipos
create extension if not exists "pgcrypto";

do $$
begin
if not exists (
select 1 from pg_type t join pg_namespace n on n.oid = t.typnamespace
where t.typname = 'series_type' and n.nspname = 'public'
) then
create type public.series_type as enum ('A','B');
end if;

if not exists (
select 1 from pg_type t join pg_namespace n on n.oid = t.typnamespace
where t.typname = 'user_role' and n.nspname = 'public'
) then
create type public.user_role as enum ('user','admin','dev_admin');
end if;
end$$;

-- Função utilitária para updated_at
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- =========================================
-- 1) CATÁLOGO: ATLÉTICAS, MODALIDADES, LOCAIS
-- (vem primeiro para permitir FKs em profiles/athletes/games)
-- =========================================

do $$ begin if not exists ( select 1 from pg_type t join pg_namespace n on n.oid = t.typnamespace where t.typname = 'naipe' and n.nspname = 'public' ) then create type public.naipe as enum ('Feminino','Masculino','Misto'); end if;end $$;

create table if not exists public.athletics (
id uuid primary key default gen_random_uuid(),
name text not null,
nickname text,
series public.series_type not null,
logo_url text,
description text,
instagram text,
twitter text,
youtube text,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);
create index if not exists idx_athletics_series on public.athletics(series);
create trigger trg_athletics_updated
before update on public.athletics
for each row execute function public.set_updated_at();

create table if not exists public.modalities (
id uuid primary key default gen_random_uuid(),
name text not null, -- ex.: Futsal
gender public.naipe not null, -- Masculino/Feminino/Misto
icon text,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);
create index if not exists idx_modalities_name on public.modalities(name);
create trigger trg_modalities_updated
before update on public.modalities
for each row execute function public.set_updated_at();

create table if not exists public.venues (
id uuid primary key default gen_random_uuid(),
name text not null,
address text,
lat double precision,
lng double precision,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);
create trigger trg_venues_updated
before update on public.venues
for each row execute function public.set_updated_at();

-- =========================================
-- 2) ATLETAS E VÍNCULOS COM MODALIDADES
-- =========================================
create table if not exists public.athletes ( id uuid primary key default gen_random_uuid(), athletic_id uuid not null references public.athletics(id) on delete cascade, full_name text not null, rga text, course text, birthdate date, created_at timestamptz not null default now(), updated_at timestamptz not null default now() ); create index if not exists idx_athletes_athletic on public.athletes(athletic_id); create trigger trg_athletes_updated before update on public.athletes for each row execute function public.set_updated_at();




-- Catálogo de métricas
create table if not exists public.stat_definitions ( code text primary key, name text not null, description text, unit text, sort_order int not null default 0 );


insert into public.stat_definitions(code, name, description, unit, sort_order) values ('GOL','Gols', null, null, 10), ('CHT','Chutes', null, null, 20), ('DEF','Defesas', null, null, 30), ('CA','Cartões Amarelos', null, null, 40), ('CV','Cartões Vermelhos', null, null, 50) on conflict (code) do nothing;

create table if not exists public.brackets  ( id uuid primary key default gen_random_uuid(), modality_id uuid not null references public.modalities(id) on delete cascade, series public.series_type not null, year int, heap_brackeat text array, created_at timestamptz not null default now(), updated_at timestamptz not null default now() );

-- =========================================
-- 3) JOGOS / CALENDÁRIO / CLASSIFICAÇÃO / CHAVEAMENTO
-- =========================================
create table if not exists public.games ( id uuid primary key default gen_random_uuid(), modality_id uuid not null references public.modalities(id), series public.series_type not null, start_at timestamptz not null, venue_id uuid references public.venues(id), a_athletic_id uuid not null references public.athletics(id), b_athletic_id uuid not null references public.athletics(id), score_a int default 0, score_b int default 0, partials jsonb default '[]', athletics_standings jsonb default '[]', winner_athletic_id uuid references public.athletics(id), status text not null default 'scheduled', -- scheduled|finished|postponed
created_at timestamptz not null default now(), updated_at timestamptz not null default now(), check (a_athletic_id <> b_athletic_id) ); create index if not exists idx_games_mod_series_start on public.games(modality_id, series, start_at); create trigger trg_games_updated before update on public.games for each row execute function public.set_updated_at();


create table if not exists public.athlete_game_stats ( game_id uuid references public.games(id) on delete cascade, athlete_id uuid references public.athletes(id) on delete cascade, stat_code text references public.stat_definitions(code) on delete cascade, value numeric not null default 0, primary key (game_id, athlete_id, stat_code) );


create table if not exists public.game_stats ( game_id uuid references public.games(id) on delete cascade, stat_code text references public.stat_definitions(code) on delete cascade, value numeric not null default 0, primary key (game_id, stat_code) );

-- =========================================
-- 4) CONTEÚDO (Notícias) e Social
-- =========================================
create table if not exists public.news ( id uuid primary key default gen_random_uuid(), title text not null, summary text, body text, image_url text, published_at timestamptz, source_url text, created_at timestamptz not null default now(), updated_at timestamptz not null default now() ); create index if not exists idx_news_published_at on public.news(published_at desc); create trigger trg_news_updated before update on public.news for each row execute function public.set_updated_at();


create table if not exists public.league_socials ( id text primary key, -- 'instagram' | 'twitter' | 'youtube'
url text not null );


-- Índices adicionais úteis
create index if not exists idx_profiles_email on public.profiles(email); create index if not exists idx_games_start_at on public.games(start_at);


-- =========================================
-- 5) Roles
-- =========================================

create table if not exists public.roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','moderator','user')),
  created_at timestamptz default now()
);


-- Um papel por usuário (ajuste se quiser permitir múltiplos)
create unique index if not exists roles_user_id_idx on public.roles(user_id);


-- ===== 2) Permissões base (necessárias além do RLS) =====
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.roles to authenticated;


-- ===== 3) RLS ON =====
alter table public.roles enable row level security;


-- Limpa policies antigas (evita conflito/loop)
drop policy if exists "Users can view their own role" on public.roles;
drop policy if exists "Admins can view all roles" on public.roles;
drop policy if exists "Admins can manage roles" on public.roles;
drop policy if exists roles_select_self_or_admin on public.roles;
drop policy if exists roles_write_admin_only on public.roles;


-- ===== 4) Função helper sem recursão =====
-- Observações:
-- - SECURITY DEFINER: executa com o dono da função (normalmente 'postgres'),
--   que não é afetado por RLS (logo, não recursa).
-- - SET search_path: evita ataques de shadowing de objetos.
create or replace function public.is_admin(p_uid uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.roles
    where user_id = p_uid and role = 'admin'
  );
$$;


-- Permitir que clientes autenticados chamem a função
revoke all on function public.is_admin(uuid) from public;
grant execute on function public.is_admin(uuid) to authenticated;


-- ===== 5) Policies da tabela roles (sem recursão) =====


-- SELECT: o usuário vê o próprio registro OU, se for admin, vê todos
create policy roles_select_self_or_admin
on public.roles
for select
to authenticated
using (
  user_id = auth.uid() OR public.is_admin(auth.uid())
);


-- INSERT/UPDATE/DELETE: apenas admins podem gerenciar
create policy roles_write_admin_only
on public.roles
for all
to authenticated
using ( public.is_admin(auth.uid()) )         -- controla UPDATE/DELETE
with check ( public.is_admin(auth.uid()) );   -- controla INSERT/UPDATE

create table if not exists public.athletic_vote (
  id uuid primary key default gen_random_uuid(),
  athletic_id uuid not null references public.athletics(id) on delete cascade,
  votante_id text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- FIM
