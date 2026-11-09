-- User funnel: unique users at each step
-- Output: data/user_funnel.csv
-- Expected: 23608 | 17623 | 12406 | 12278 | 6233 | 6233 | 4348

SELECT
    funnel_step,
    CASE funnel_step
        WHEN 1 THEN 'download'
        WHEN 2 THEN 'signup'
        WHEN 3 THEN 'ride_requested'
        WHEN 4 THEN 'ride_accepted'
        WHEN 5 THEN 'ride_completed'
        WHEN 6 THEN 'payment'
        WHEN 7 THEN 'review'
    END                     AS funnel_name,
    SUM(number_of_users)    AS users
FROM funnel_analysis
GROUP BY funnel_step
ORDER BY funnel_step;
