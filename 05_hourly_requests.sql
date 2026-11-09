-- Ride requests by hour of day
-- Output: data/hourly_requests.csv
-- Expected peaks: 8h 60071, 9h 60210, 16h 58527, 17h 58176, 18h 40372, 19h 39495

SELECT
    EXTRACT(HOUR FROM request_ts)::int  AS hour_of_day,
    COUNT(*)                            AS total_requests
FROM ride_requests
GROUP BY 1
ORDER BY 1;
