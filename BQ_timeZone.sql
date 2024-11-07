WITH coordinates AS (
  SELECT ST_GeogPoint(longitude, latitude) AS point
  FROM UNNEST([
    STRUCT(-122.4194 AS longitude, 37.7749 AS latitude),  -- Example: San Francisco
    STRUCT(-74.0060 AS longitude, 40.7128 AS latitude)    -- Example: New York
  ])
),
timezones AS (
  SELECT
    timezone_name,
    timezone_boundary
  FROM `bigquery-public-data.timezone_boundaries.table` -- replace with actual dataset
)
SELECT
  t.timezone_name,
  c.point
FROM coordinates c
JOIN timezones t
ON ST_Contains(t.timezone_boundary, c.point)
