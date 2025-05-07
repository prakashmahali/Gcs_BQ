WITH job_labels AS (
  SELECT
    job_id,
    creation_time,
    end_time,
    total_slot_ms,
    state,
    error_result,
    (
      SELECT value FROM UNNEST(labels)
      WHERE key = 'dag_id'
    ) AS dag_id,
    (
      SELECT value FROM UNNEST(labels)
      WHERE key = 'task_id'
    ) AS task_id,
    (
      SELECT value FROM UNNEST(labels)
      WHERE key = 'dag_run_id'
    ) AS dag_run_id
  FROM
    `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
  WHERE
    creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY) AND CURRENT_TIMESTAMP()
    AND job_type = 'QUERY'
)
SELECT
  dag_run_id,
  SUM(total_slot_ms) / 1000.0 AS total_slot_seconds
FROM
  job_labels
WHERE
  dag_id = 'load_collect'
GROUP BY
  dag_run_id
ORDER BY
  dag_run_id DESC;
