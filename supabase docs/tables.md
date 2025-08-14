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
gender text not null, -- Masculino/Feminino/Misto
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
-- 2) PROFILES (1:1 com auth.users) – agora pode referenciar athletics
-- =========================================
create table if not exists public.profiles (
id uuid primary key references auth.users(id) on delete cascade,
email text not null unique,
full_name text,
avatar_url text,
role public.user_role not null default 'user',

selected_athletic_id uuid references public.athletics(id)
on update cascade on delete set null,

accepted_terms_at timestamptz,
notifications_enabled boolean not null default false,
marketing_opt_in boolean not null default false,

disabled boolean not null default false,
metadata jsonb not null default '{}',

created_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);
create index if not exists idx_profiles_selected_athletic
on public.profiles (selected_athletic_id);
create trigger trg_profiles_updated
before update on public.profiles
for each row execute function public.set_updated_at();

-- Auto-criação do profile quando nasce um usuário no auth
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url, metadata)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', null),
    coalesce(new.raw_user_meta_data ->> 'avatar_url', null),
    coalesce(new.raw_user_meta_data, '{}'::jsonb)
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- =========================================
-- 3) ATLETAS E VÍNCULOS COM MODALIDADES
-- =========================================
create table if not exists public.athletes (
id uuid primary key default gen_random_uuid(),
athletic_id uuid not null references public.athletics(id) on delete cascade,
full_name text not null,
rga text,
course text,
birthdate date,
photo_url text,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);
create index if not exists idx_athletes_athletic on public.athletes(athletic_id);
create trigger trg_athletes_updated
before update on public.athletes
for each row execute function public.set_updated_at();

create table if not exists public.athlete_modalities (
athlete_id uuid references public.athletes(id) on delete cascade,
modality_id uuid references public.modalities(id) on delete cascade,
jersey_number int,
position text,
primary key (athlete_id, modality_id)
);

-- Catálogo de métricas
create table if not exists public.stat_definitions (
code text primary key, -- ex.: 'GOL','CHT','DEF','CA','CV'
name text not null,
description text,
unit text,
sort_order int not null default 0
);

insert into public.stat_definitions(code, name, description, unit, sort_order) values
('GOL','Gols', null, null, 10),
('CHT','Chutes', null, null, 20),
('DEF','Defesas', null, null, 30),
('CA','Cartões Amarelos', null, null, 40),
('CV','Cartões Vermelhos', null, null, 50)
on conflict (code) do nothing;

-- =========================================
-- 4) JOGOS / CALENDÁRIO / CLASSIFICAÇÃO / CHAVEAMENTO
-- =========================================
create table if not exists public.games (
id uuid primary key default gen_random_uuid(),
modality_id uuid not null references public.modalities(id),
series public.series_type not null,
start_at timestamptz not null,
venue_id uuid references public.venues(id),
home_athletic_id uuid not null references public.athletics(id),
away_athletic_id uuid not null references public.athletics(id),
score_home int default 0,
score_away int default 0,
partials jsonb default '[]',
winner_athletic_id uuid references public.athletics(id),
status text not null default 'scheduled', -- scheduled|finished|postponed
created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),
check (home_athletic_id <> away_athletic_id)
);
create index if not exists idx_games_mod_series_start
on public.games(modality_id, series, start_at);
create trigger trg_games_updated
before update on public.games
for each row execute function public.set_updated_at();

-- Estatística de atleta NO JOGO (depende de games, então vem depois)
create table if not exists public.athlete_game_stats (
game_id uuid references public.games(id) on delete cascade,
athlete_id uuid references public.athletes(id) on delete cascade,
stat_code text references public.stat_definitions(code) on delete cascade,
value numeric not null default 0,
primary key (game_id, athlete_id, stat_code)
);

-- Snapshot simples de classificação
create table if not exists public.standings (
series public.series_type not null,
athletic_id uuid not null references public.athletics(id) on delete cascade,
points int not null default 0,
games_played int not null default 0,
wins int not null default 0,
draws int not null default 0,
losses int not null default 0,
goals_for int not null default 0,
goals_against int not null default 0,
primary key (series, athletic_id)
);

-- Chaveamento por fase
create table if not exists public.brackets (
id uuid primary key default gen_random_uuid(),
modality_id uuid not null references public.modalities(id) on delete cascade,
series public.series_type not null,
stage text not null, -- round_of_16 | quarterfinal | semifinal | final
game_id uuid references public.games(id) on delete set null,
seed_home int,
seed_away int,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);
create trigger trg_brackets_updated
before update on public.brackets
for each row execute function public.set_updated_at();

-- =========================================
-- 5) CONTEÚDO (Notícias) e Social
-- =========================================
create table if not exists public.news (
id uuid primary key default gen_random_uuid(),
title text not null,
summary text,
body text,
image_url text,
published_at timestamptz,
source_url text,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);
create index if not exists idx_news_published_at on public.news(published_at desc);
create trigger trg_news_updated
before update on public.news
for each row execute function public.set_updated_at();

create table if not exists public.league_socials (
id text primary key, -- 'instagram' | 'twitter' | 'youtube'
url text not null
);

-- Índices adicionais úteis
create index if not exists idx_profiles_email on public.profiles(email);
create index if not exists idx_games_start_at on public.games(start_at);

-- FIM
