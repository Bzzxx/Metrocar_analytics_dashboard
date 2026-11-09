-- Users by age group at signup (age is not available for later steps)
-- Output: data/age_at_signup.csv
-- Expected: 18-24 1865 | 25-34 3447 | 35-44 5181 | 45-54 1826 | Unknown 5304

SELECT
    COALESCE(age_range, 'Unknown')  AS age_range,
    'signup'                        AS funnel_name,
    SUM(number_of_users)            AS users
FROM funnel_analysis
WHERE funnel_step = 2
GROUP BY COALESCE(age_range, 'Unknown')
ORDER BY age_range;
