-- Monthly funnel trends with month-over-month change
-- Source: funnel_analysis / raw Metrocar tables (PostgreSQL)

WITH monthly_funnel AS (
    SELECT 
        DATE_TRUNC('month', download_date) AS month,
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
    WHERE download_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', download_date), funnel_step
),
monthly_conversions AS (
    SELECT 
        month,
        MAX(CASE WHEN funnel_step = 1 THEN users_count END) AS downloads,
        MAX(CASE WHEN funnel_step = 2 THEN users_count END) AS signups,
        MAX(CASE WHEN funnel_step = 3 THEN users_count END) AS ride_requests,
        MAX(CASE WHEN funnel_step = 5 THEN users_count END) AS ride_completes,
        MAX(CASE WHEN funnel_step = 6 THEN users_count END) AS payments,
        MAX(CASE WHEN funnel_step = 7 THEN users_count END) AS reviews
    FROM monthly_funnel
    GROUP BY month
)
SELECT 
    month,
    downloads,
    signups,
    ride_requests,
    ride_completes,
    payments,
    reviews,
    -- Конверсії
    ROUND(100.0 * signups / NULLIF(downloads, 0), 2) AS download_to_signup_pct,
    ROUND(100.0 * ride_requests / NULLIF(signups, 0), 2) AS signup_to_request_pct,
    ROUND(100.0 * ride_completes / NULLIF(ride_requests, 0), 2) AS request_to_complete_pct,
    ROUND(100.0 * payments / NULLIF(ride_completes, 0), 2) AS complete_to_payment_pct,
    -- Загальна конверсія
    ROUND(100.0 * payments / NULLIF(downloads, 0), 2) AS overall_conversion_pct,
    -- Зміна від попереднього місяця
    ROUND(100.0 * payments / NULLIF(downloads, 0), 2) - 
        LAG(ROUND(100.0 * payments / NULLIF(downloads, 0), 2)) OVER (ORDER BY month) AS conversion_change_from_prev_month
FROM monthly_conversions
ORDER BY month;