-- Function to get athletic games for a specific date
-- This function should be created in your Supabase SQL editor

CREATE OR REPLACE FUNCTION get_athletic_games(
  athletic_id_param UUID,
  date_param DATE
)
RETURNS TABLE(
  game_id UUID,
  start_at TIMESTAMPTZ,
  status TEXT,
  modality_phase TEXT,
  venue_name TEXT,
  team_a_id UUID,
  team_a_logo TEXT,
  team_b_id UUID,
  team_b_logo TEXT,
  score_a INTEGER,
  score_b INTEGER
)
LANGUAGE SQL
AS $$
  SELECT
    games.id AS game_id,
    games.start_at,
    games.status,
    CONCAT(
      modalities.name, ' ', modalities.gender, ' - ',
      CASE
        WHEN bracket_info.position = 1 THEN 'Final'
        WHEN bracket_info.position BETWEEN 2 AND 3 THEN 'Semifinal'
        WHEN bracket_info.position BETWEEN 4 AND 7 THEN 'Quartas'
        WHEN bracket_info.position BETWEEN 8 AND 15 THEN 'Oitavas'
        ELSE ''
      END
    ) AS modality_phase,
    venues.name AS venue_name,
    team_a.id AS team_a_id,
    team_a.logo_url AS team_a_logo,
    team_b.id AS team_b_id,
    team_b.logo_url AS team_b_logo,
    games.score_a,
    games.score_b
  FROM
    games
  JOIN
    modalities ON games.modality_id = modalities.id
  LEFT JOIN
    venues ON games.venue_id = venues.id
  LEFT JOIN
    athletics AS team_a ON games.a_athletic_id = team_a.id
  LEFT JOIN
    athletics AS team_b ON games.b_athletic_id = team_b.id
  LEFT JOIN (
    SELECT
      t.game_id, t.position
    FROM
      brackets, unnest(brackets.heap_brackeat) WITH ordinality AS t(game_id, position)
  ) AS bracket_info ON games.id = bracket_info.game_id::uuid
  WHERE
    (games.a_athletic_id = athletic_id_param OR games.b_athletic_id = athletic_id_param) 
    AND games.start_at::DATE = date_param
  ORDER BY
    games.start_at ASC;
$$;