-- User segmentation by number of rides, platform and age
-- Source: funnel_analysis / raw Metrocar tables (PostgreSQL)

WITH user_rides AS (
    SELECT 
        s.user_id,
        s.platform,
        s.age_range,
        COUNT(DISTINCT rq.ride_id) AS total_rides,
        COUNT(DISTINCT CASE WHEN rq.dropoff_ts IS NOT NULL THEN rq.ride_id END) AS completed_rides,
        SUM(t.purchase_amount_usd) AS total_spent
    FROM signups s
    LEFT JOIN ride_requests rq ON s.user_id = rq.user_id
    LEFT JOIN transactions t ON rq.ride_id = t.ride_id AND t.charge_status = 'Approved'
    GROUP BY s.user_id, s.platform, s.age_range
),
user_segments AS (
    SELECT 
        CASE 
            WHEN total_rides = 0 THEN '0 - No Rides'
            WHEN total_rides = 1 THEN '1 - One-time User'
            WHEN total_rides BETWEEN 2 AND 5 THEN '2 - Occasional (2-5 rides)'
            WHEN total_rides BETWEEN 6 AND 10 THEN '3 - Regular (6-10 rides)'
            ELSE '4 - Power User (10+ rides)'
        END AS user_segment,
        platform,
        age_range,
        COUNT(*) AS number_of_users,
        AVG(total_rides) AS avg_rides,
        AVG(completed_rides) AS avg_completed_rides,
        AVG(total_spent) AS avg_lifetime_value
    FROM user_rides
    GROUP BY user_segment, platform, age_range
)
SELECT 
    user_segment,
    platform,
    age_range,
    number_of_users,
    ROUND(avg_rides, 2) AS avg_rides_per_user,
    ROUND(avg_completed_rides, 2) AS avg_completed_rides,
    ROUND(avg_lifetime_value, 2) AS avg_lifetime_value_usd,
    ROUND(100.0 * number_of_users / SUM(number_of_users) OVER (PARTITION BY platform), 2) AS pct_of_platform_users
FROM user_segments
ORDER BY user_segment, platform, number_of_users DESC;
