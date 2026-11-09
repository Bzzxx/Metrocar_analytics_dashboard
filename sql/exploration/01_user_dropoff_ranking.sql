-- Users lost at each funnel step, ranked by size of the drop
-- Source: funnel_analysis / raw Metrocar tables (PostgreSQL)

WITH funnel_summary AS (
    SELECT 
        funnel_step,
        CASE funnel_step
            WHEN 1 THEN 'app_download'
            WHEN 2 THEN 'signup'
            WHEN 3 THEN 'ride_requested'
            WHEN 4 THEN 'ride_accepted'
            WHEN 5 THEN 'ride_completed'
            WHEN 6 THEN 'payment'
            WHEN 7 THEN 'review'
        END AS funnel_step_name,
        SUM(number_of_users) AS total_users
    FROM funnel_analysis
    GROUP BY funnel_step
),
user_drops AS (
    SELECT 
        funnel_step,
        funnel_step_name,
        total_users,
        LAG(total_users) OVER (ORDER BY funnel_step) AS previous_step_users,
        LAG(total_users) OVER (ORDER BY funnel_step) - total_users AS users_lost
    FROM funnel_summary
)
SELECT 
    funnel_step_name AS transition,
    users_lost,
    previous_step_users AS users_at_previous_step,
    total_users AS users_at_current_step,
    ROUND(100.0 * users_lost / NULLIF(previous_step_users, 0), 2) AS pct_of_users_lost,
    -- Ранг по втратам
    RANK() OVER (ORDER BY users_lost DESC) AS loss_rank
FROM user_drops
WHERE users_lost IS NOT NULL
ORDER BY users_lost DESC;

