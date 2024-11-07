WITH location AS (
  SELECT ST_GEOGPOINT(lon, lat) AS point
  FROM UNNEST([STRUCT(34.0522 AS lat, -118.2437 AS lon)]) -- Replace with your lat/lon
)
SELECT
  tz.time_zone,
  tz.utc_offset
FROM
  bigquery-public-data.world_geography.timezone_boundary AS tz
JOIN
  location
ON
  ST_CONTAINS(tz.timezone_geometry, location.point)
