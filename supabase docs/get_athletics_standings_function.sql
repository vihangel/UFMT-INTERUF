-- SQL function to be created in Supabase Dashboard
-- This should be executed in the SQL Editor of your Supabase project

CREATE OR REPLACE FUNCTION get_athletics_standings(series_filter TEXT)
RETURNS TABLE (
    name TEXT,
    gold_medals BIGINT,
    silver_medals BIGINT,
    bronze_medals BIGINT,
    fourth_places BIGINT,
    total_medals BIGINT,
    points BIGINT
)
LANGUAGE SQL
AS $$
WITH bracket_games AS (
    -- Get all games that are part of brackets with their position in the bracket
    SELECT
        unnest(b.heap_brackeat) AS game_id,
        generate_subscripts(b.heap_brackeat, 1) AS position
    FROM brackets b
),
standings_rankings AS (
    -- Pre-calculate rankings for standings-style games
    SELECT
        g.id as game_id,
        g.modality_id,
        athletic_data.athletic_id::uuid as athletic_id,
        row_number() OVER (PARTITION BY g.id ORDER BY athletic_data.ordinality) as rank
    FROM games g
    CROSS JOIN LATERAL jsonb_array_elements_text(g.athletics_standings->'id_atletics') WITH ORDINALITY AS athletic_data(athletic_id, ordinality)
    WHERE g.a_athletic_id IS NULL
    AND g.b_athletic_id IS NULL
    AND g.athletics_standings ? 'id_atletics'  -- More efficient existence check
    AND jsonb_typeof(g.athletics_standings->'id_atletics') = 'array'
),
medal_counts AS (
    -- Gold medals: winners of final games (position 1 in bracket)
    SELECT
        a.id,
        a.name,
        'gold' as medal_type,
        g.modality_id,
        COUNT(*) as medals
    FROM games g
    inner JOIN bracket_games bg ON g.id::text = bg.game_id AND bg.position = 1  -- Avoid casting in join condition
    JOIN athletics a ON a.id = g.winner_athletic_id
    WHERE g.winner_athletic_id IS NOT NULL  -- Ensure there's a winner
    GROUP BY a.id, a.name, g.modality_id
   
    UNION ALL
   
    -- Silver medals: losers of final games (position 1 in bracket)
    SELECT
        a.id,
        a.name,
        'silver' as medal_type,
        g.modality_id,
        COUNT(*) as medals
    FROM games g
    JOIN bracket_games bg ON g.id::text = bg.game_id AND bg.position = 1
    JOIN athletics a ON (a.id = g.a_athletic_id OR a.id = g.b_athletic_id)
                    AND a.id != g.winner_athletic_id
    WHERE g.winner_athletic_id IS NOT NULL
    AND g.a_athletic_id IS NOT NULL
    AND g.b_athletic_id IS NOT NULL
    GROUP BY a.id, a.name, g.modality_id
   
    UNION ALL
   
    -- Bronze medals: losers of semifinals to the bracket winner
    SELECT
        a.id,
        a.name,
        'bronze' as medal_type,
        semifinal.modality_id,
        COUNT(*) as medals
    FROM games semifinal
    JOIN bracket_games bg_semi ON semifinal.id::text = bg_semi.game_id
                              AND bg_semi.position IN (2, 3)
    -- Find the bracket this semifinal belongs to and get its winner
    JOIN brackets b ON bg_semi.game_id = ANY(b.heap_brackeat)
    JOIN games final_game ON final_game.id::text = b.heap_brackeat[1]  -- First element is final
    JOIN athletics a ON (a.id = semifinal.a_athletic_id OR a.id = semifinal.b_athletic_id)
                    AND a.id != semifinal.winner_athletic_id
    WHERE semifinal.winner_athletic_id = final_game.winner_athletic_id  -- Semifinal winner became bracket winner
    AND semifinal.winner_athletic_id IS NOT NULL
    AND final_game.winner_athletic_id IS NOT NULL
    GROUP BY a.id, a.name, semifinal.modality_id
   
    UNION ALL
   
    -- 4th place: other losers of semifinals (who didn't lose to the bracket winner)
    SELECT
        a.id,
        a.name,
        'fourth' as medal_type,
        semifinal.modality_id,
        COUNT(*) as medals
    FROM games semifinal
    JOIN bracket_games bg_semi ON semifinal.id::text = bg_semi.game_id
                              AND bg_semi.position IN (2, 3)
    JOIN brackets b ON bg_semi.game_id = ANY(b.heap_brackeat)
    JOIN games final_game ON final_game.id::text = b.heap_brackeat[1]
    JOIN athletics a ON (a.id = semifinal.a_athletic_id OR a.id = semifinal.b_athletic_id)
                    AND a.id != semifinal.winner_athletic_id
    WHERE semifinal.winner_athletic_id != final_game.winner_athletic_id  -- Semifinal winner did NOT become bracket winner
    AND semifinal.winner_athletic_id IS NOT NULL
    AND final_game.winner_athletic_id IS NOT NULL
    GROUP BY a.id, a.name, semifinal.modality_id
   
    UNION ALL
   
    -- Gold medals from standings-style games
    SELECT
        a.id,
        a.name,
        'gold' as medal_type,
        sr.modality_id,
        COUNT(*) as medals
    FROM standings_rankings sr
    JOIN athletics a ON a.id = sr.athletic_id
    WHERE sr.rank = 1
    GROUP BY a.id, a.name, sr.modality_id
   
    UNION ALL
   
    -- Silver medals from standings-style games
    SELECT
        a.id,
        a.name,
        'silver' as medal_type,
        sr.modality_id,
        COUNT(*) as medals
    FROM standings_rankings sr
    JOIN athletics a ON a.id = sr.athletic_id
    WHERE sr.rank = 2
    GROUP BY a.id, a.name, sr.modality_id
   
    UNION ALL
   
    -- Bronze medals from standings-style games
    SELECT
        a.id,
        a.name,
        'bronze' as medal_type,
        sr.modality_id,
        COUNT(*) as medals
    FROM standings_rankings sr
    JOIN athletics a ON a.id = sr.athletic_id
    WHERE sr.rank = 3
    GROUP BY a.id, a.name, sr.modality_id
   
    UNION ALL
   
    -- 4th place from standings-style games
    SELECT
        a.id,
        a.name,
        'fourth' as medal_type,
        sr.modality_id,
        COUNT(*) as medals
    FROM standings_rankings sr
    JOIN athletics a ON a.id = sr.athletic_id
    WHERE sr.rank = 4
    GROUP BY a.id, a.name, sr.modality_id
)
SELECT
    a.name,
    COALESCE(SUM(CASE WHEN mc.medal_type = 'gold' THEN mc.medals ELSE 0 END), 0) as gold_medals,
    COALESCE(SUM(CASE WHEN mc.medal_type = 'silver' THEN mc.medals ELSE 0 END), 0) as silver_medals,
    COALESCE(SUM(CASE WHEN mc.medal_type = 'bronze' THEN mc.medals ELSE 0 END), 0) as bronze_medals,
    COALESCE(SUM(CASE WHEN mc.medal_type = 'fourth' THEN mc.medals ELSE 0 END), 0) as fourth_places,
    COALESCE(SUM(mc.medals), 0) as total_medals,
    COALESCE(SUM(
        CASE
            WHEN mc.medal_type = 'gold' THEN
                mc.medals * CASE WHEN mc.modality_id = '3fadab85-6b30-47d2-b1d7-76884342292f' THEN 50 ELSE 100 END
            WHEN mc.medal_type = 'silver' THEN
                mc.medals * CASE WHEN mc.modality_id = '3fadab85-6b30-47d2-b1d7-76884342292f' THEN 20 ELSE 50 END
            WHEN mc.medal_type = 'bronze' THEN
                mc.medals * CASE WHEN mc.modality_id = '3fadab85-6b30-47d2-b1d7-76884342292f' THEN 10 ELSE 20 END
            WHEN mc.medal_type = 'fourth' THEN
                mc.medals * CASE WHEN mc.modality_id = '3fadab85-6b30-47d2-b1d7-76884342292f' THEN 5 ELSE 10 END
            ELSE 0
        END
    ), 0) as points
FROM athletics a
LEFT JOIN medal_counts mc ON a.id = mc.id  -- Join on ID instead of name for better performance
WHERE a.series = series_filter
GROUP BY a.id, a.name
ORDER BY points DESC, gold_medals DESC, silver_medals DESC, bronze_medals DESC, a.name;
$$;