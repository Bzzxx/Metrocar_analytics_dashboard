-- Cancellation rate by driver wait time (request -> driver acceptance)
-- Output: data/wait_time_cancellation.csv
-- Expected: < 5 min 74720 / 0.00 | 5-10 min 151124 / 1.45 | > 10 min 22535 / 100.00 | not_accepted 137098 / 100.00

WITH rides AS (
    SELECT
        ride_id,
        cancel_ts,
        CASE
            WHEN accept_ts IS NULL                         THEN 'not_accepted'
            WHEN accept_ts - request_ts <  INTERVAL '5 minutes'  THEN '< 5 min'
            WHEN accept_ts - request_ts <= INTERVAL '10 minutes' THEN '5-10 min'
            ELSE '> 10 min'
        END AS wait_time_group
    FROM ride_requests
)
SELECT
    wait_time_group,
    COUNT(*)                                                    AS rides,
    ROUND(100.0 * COUNT(cancel_ts) / COUNT(*), 2)               AS cancellation_rate
FROM rides
GROUP BY wait_time_group
ORDER BY wait_time_group;
