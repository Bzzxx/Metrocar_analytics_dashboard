-- Ride funnel: number of rides at each step (download and signup have no rides)
-- Output: data/ride_funnel.csv
-- Expected: 0 | 0 | 385477 | 248379 | 223652 | 212628 | 156211

SELECT 1 AS funnel_step, 'download' AS funnel_name, 0 AS rides
UNION ALL
SELECT 2, 'signup', 0
UNION ALL
SELECT 3, 'ride_requested', COUNT(*) FROM ride_requests
UNION ALL
SELECT 4, 'ride_accepted', COUNT(*) FROM ride_requests WHERE accept_ts IS NOT NULL
UNION ALL
SELECT 5, 'ride_completed', COUNT(*) FROM ride_requests WHERE dropoff_ts IS NOT NULL
UNION ALL
SELECT 6, 'payment', COUNT(*) FROM transactions WHERE charge_status = 'Approved'
UNION ALL
SELECT 7, 'review', COUNT(*) FROM reviews
ORDER BY funnel_step;
