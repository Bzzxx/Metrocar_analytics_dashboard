-- Ride cancellation rate by day of week
-- Output: data/day_of_week_cancellation.csv
-- Expected: about 55,000 rides and 42% cancellation every day

SELECT
    TO_CHAR(request_ts, 'Dy')                           AS day_of_week,
    COUNT(*)                                            AS total_rides,
    COUNT(cancel_ts)                                    AS cancelled_rides,
    ROUND(100.0 * COUNT(cancel_ts) / COUNT(*), 2)       AS cancellation_rate
FROM ride_requests
GROUP BY TO_CHAR(request_ts, 'Dy'), EXTRACT(DOW FROM request_ts)
ORDER BY EXTRACT(DOW FROM request_ts);
