-- Ride completion rate by age group
-- Source: funnel_analysis / raw Metrocar tables (PostgreSQL)

SELECT
    s.age_range,
    COUNT(DISTINCT r.user_id) AS users_requested,
    COUNT(DISTINCT CASE WHEN r.dropoff_ts IS NOT NULL THEN r.user_id END) AS users_completed,
    ROUND(
        COUNT(DISTINCT CASE WHEN r.dropoff_ts IS NOT NULL THEN r.user_id END)::numeric
        / COUNT(DISTINCT r.user_id) * 100,
        2
    ) AS completion_rate
FROM ride_requests r
JOIN signups s ON r.user_id = s.user_id
GROUP BY s.age_range
ORDER BY completion_rate DESC;






