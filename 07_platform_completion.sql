-- Ride completion rate by platform: users who requested a ride vs users who completed one
-- Output: data/platform_completion.csv
-- Expected: android 3619 / 1830 / 50.57 | ios 7550 / 3792 / 50.23 | web 1237 / 611 / 49.39

SELECT
    a.platform,
    COUNT(DISTINCT r.user_id)                                                   AS users_requested_ride,
    COUNT(DISTINCT CASE WHEN r.dropoff_ts IS NOT NULL THEN r.user_id END)       AS users_completed_ride,
    ROUND(
        COUNT(DISTINCT CASE WHEN r.dropoff_ts IS NOT NULL THEN r.user_id END)::numeric
        / COUNT(DISTINCT r.user_id) * 100,
        2
    )                                                                           AS completion_rate
FROM ride_requests r
JOIN signups s       ON r.user_id = s.user_id
JOIN app_downloads a ON s.session_id = a.app_download_key
GROUP BY a.platform
ORDER BY a.platform;
