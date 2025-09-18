<!-- @format -->

-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.athlete_game (
game_id uuid NOT NULL,
athlete_id uuid NOT NULL,
shirt_number numeric NOT NULL,
CONSTRAINT athlete_game_pkey PRIMARY KEY (game_id, athlete_id),
CONSTRAINT athlete_game_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id),
CONSTRAINT athlete_game_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id)
);
CREATE TABLE public.athlete_game_stats (
game_id uuid NOT NULL,
athlete_id uuid NOT NULL,
stat_code text NOT NULL,
value numeric NOT NULL DEFAULT 0,
CONSTRAINT athlete_game_stats_pkey PRIMARY KEY (stat_code, athlete_id, game_id),
CONSTRAINT athlete_game_stats_stat_code_fkey FOREIGN KEY (stat_code) REFERENCES public.stat_definitions(code),
CONSTRAINT athlete_game_stats_game_id_athlete_id_fkey FOREIGN KEY (game_id) REFERENCES public.athlete_game(game_id),
CONSTRAINT athlete_game_stats_game_id_athlete_id_fkey FOREIGN KEY (game_id) REFERENCES public.athlete_game(athlete_id),
CONSTRAINT athlete_game_stats_game_id_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athlete_game(game_id),
CONSTRAINT athlete_game_stats_game_id_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athlete_game(athlete_id)
);
CREATE TABLE public.athletes (
id uuid NOT NULL DEFAULT gen_random_uuid(),
athletic_id uuid NOT NULL,
full_name text NOT NULL,
rga text,
course text,
birthdate date,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT athletes_pkey PRIMARY KEY (id),
CONSTRAINT athletes_athletic_id_fkey FOREIGN KEY (athletic_id) REFERENCES public.athletics(id)
);
CREATE TABLE public.athletic_vote (
id uuid NOT NULL DEFAULT gen_random_uuid(),
athletic_id uuid NOT NULL,
votante_id text NOT NULL,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT athletic_vote_pkey PRIMARY KEY (id),
CONSTRAINT athletic_vote_athletic_id_fkey FOREIGN KEY (athletic_id) REFERENCES public.athletics(id)
);
CREATE TABLE public.athletics (
id uuid NOT NULL DEFAULT gen_random_uuid(),
name text NOT NULL,
nickname text,
series USER-DEFINED NOT NULL,
logo_url text,
description text,
instagram text,
twitter text,
youtube text,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT athletics_pkey PRIMARY KEY (id)
);
CREATE TABLE public.brackets (
id uuid NOT NULL DEFAULT gen_random_uuid(),
modality_id uuid NOT NULL,
series USER-DEFINED NOT NULL,
year integer,
heap_brackeat ARRAY,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT brackets_pkey PRIMARY KEY (id),
CONSTRAINT brackets_modality_id_fkey FOREIGN KEY (modality_id) REFERENCES public.modalities(id)
);
CREATE TABLE public.game_stats (
game_id uuid NOT NULL,
stat_code text NOT NULL,
value numeric NOT NULL DEFAULT 0,
CONSTRAINT game_stats_pkey PRIMARY KEY (stat_code, game_id),
CONSTRAINT game_stats_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id),
CONSTRAINT game_stats_stat_code_fkey FOREIGN KEY (stat_code) REFERENCES public.stat_definitions(code)
);
CREATE TABLE public.games (
id uuid NOT NULL DEFAULT gen_random_uuid(),
modality_id uuid NOT NULL,
series USER-DEFINED NOT NULL,
start_at timestamp with time zone NOT NULL,
venue_id uuid,
a_athletic_id uuid,
b_athletic_id uuid,
score_a integer DEFAULT 0,
score_b integer DEFAULT 0,
partials jsonb DEFAULT '[]'::jsonb,
athletics_standings jsonb DEFAULT '[]'::jsonb,
winner_athletic_id uuid,
status text NOT NULL DEFAULT 'scheduled'::text,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT games_pkey PRIMARY KEY (id),
CONSTRAINT games_modality_id_fkey FOREIGN KEY (modality_id) REFERENCES public.modalities(id),
CONSTRAINT games_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(id),
CONSTRAINT games_a_athletic_id_fkey FOREIGN KEY (a_athletic_id) REFERENCES public.athletics(id),
CONSTRAINT games_b_athletic_id_fkey FOREIGN KEY (b_athletic_id) REFERENCES public.athletics(id),
CONSTRAINT games_winner_athletic_id_fkey FOREIGN KEY (winner_athletic_id) REFERENCES public.athletics(id)
);
CREATE TABLE public.league_socials (
id text NOT NULL,
url text NOT NULL,
CONSTRAINT league_socials_pkey PRIMARY KEY (id)
);
CREATE TABLE public.modalities (
id uuid NOT NULL DEFAULT gen_random_uuid(),
name text NOT NULL,
gender USER-DEFINED NOT NULL,
icon text,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT modalities_pkey PRIMARY KEY (id)
);
CREATE TABLE public.news (
id uuid NOT NULL DEFAULT gen_random_uuid(),
title text NOT NULL,
summary text,
body text,
image_url text,
published_at timestamp with time zone,
source_url text,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT news_pkey PRIMARY KEY (id)
);
CREATE TABLE public.roles (
id uuid NOT NULL DEFAULT gen_random_uuid(),
user_id uuid NOT NULL,
role text NOT NULL CHECK (role = ANY (ARRAY['admin'::text, 'moderator'::text, 'user'::text])),
created_at timestamp with time zone DEFAULT now(),
CONSTRAINT roles_pkey PRIMARY KEY (id),
CONSTRAINT roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.stat_definitions (
code text NOT NULL,
name text NOT NULL,
description text,
unit text,
sort_order integer NOT NULL DEFAULT 0,
CONSTRAINT stat_definitions_pkey PRIMARY KEY (code)
);
CREATE TABLE public.venues (
id uuid NOT NULL DEFAULT gen_random_uuid(),
name text NOT NULL,
address text,
lat double precision,
lng double precision,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT venues_pkey PRIMARY KEY (id)
);
