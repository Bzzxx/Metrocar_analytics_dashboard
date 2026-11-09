-- Funnel conversion by platform (iOS / Android / web)
-- Source: funnel_analysis / raw Metrocar tables (PostgreSQL)

WITH platform_funnel AS (
    SELECT 
        platform,
        CASE funnel_step
            WHEN 1 THEN 'app_download'
            WHEN 2 THEN 'signup'
            WHEN 3 THEN 'ride_requested'
            WHEN 4 THEN 'ride_accepted'
            WHEN 5 THEN 'ride_completed'
            WHEN 6 THEN 'payment'
            WHEN 7 THEN 'review'
        END AS funnel_step_name,
        funnel_step,
        SUM(number_of_users) AS users_count
    FROM funnel_analysis
    GROUP BY platform, funnel_step
),
platform_conversions AS (
    SELECT 
        platform,
        MAX(CASE WHEN funnel_step = 1 THEN users_count END) AS downloads,
        MAX(CASE WHEN funnel_step = 2 THEN users_count END) AS signups,
        MAX(CASE WHEN funnel_step = 3 THEN users_count END) AS ride_requests,
        MAX(CASE WHEN funnel_step = 4 THEN users_count END) AS ride_accepts,
        MAX(CASE WHEN funnel_step = 5 THEN users_count END) AS ride_completes,
        MAX(CASE WHEN funnel_step = 6 THEN users_count END) AS payments,
        MAX(CASE WHEN funnel_step = 7 THEN users_count END) AS reviews
    FROM platform_funnel
    GROUP BY platform
)
SELECT 
    platform,
    downloads,
    signups,
    ride_requests,
    ride_completes,
    payments,
    reviews,
    -- Ключові конверсії
    ROUND(100.0 * signups / NULLIF(downloads, 0), 2) AS download_to_signup_pct,
    ROUND(100.0 * ride_requests / NULLIF(signups, 0), 2) AS signup_to_request_pct,
    ROUND(100.0 * ride_completes / NULLIF(ride_requests, 0), 2) AS request_to_complete_pct,
    ROUND(100.0 * payments / NULLIF(ride_completes, 0), 2) AS complete_to_payment_pct,
    ROUND(100.0 * reviews / NULLIF(payments, 0), 2) AS payment_to_review_pct,
    -- Загальна конверсія
    ROUND(100.0 * payments / NULLIF(downloads, 0), 2) AS overall_conversion_pct
FROM platform_conversions
ORDER BY downloads DESC;
