SELECT
  job_id,
  user_email,
  start_time,
  end_time,
  TIMESTAMP_TRUNC(start_time, HOUR) AS hour,
  statement_type,
  total_slot_ms,
  referenced_tables
FROM
  `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE
  DATE(start_time) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)  -- or a specific date
  AND statement_type IN ('QUERY', 'INSERT', 'MERGE')
  AND referenced_tables IS NOT NULL
  AND EXISTS (
    SELECT 1
    FROM UNNEST(referenced_tables) AS t
    WHERE t.table_id = 'order_data'
  )
#Aggregated by hour 
SELECT
  TIMESTAMP_TRUNC(start_time, HOUR) AS hour,
  statement_type,
  COUNT(*) AS job_count,
  SUM(total_slot_ms) AS total_slot_ms,
  ROUND(SUM(total_slot_ms) / 1000.0, 2) AS slot_seconds
FROM
  `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE
  DATE(start_time) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND statement_type IN ('QUERY', 'INSERT', 'MERGE')
  AND EXISTS (
    SELECT 1
    FROM UNNEST(referenced_tables) AS t
    WHERE t.table_id = 'order_data'
  )
GROUP BY hour, statement_type
ORDER BY hour;
