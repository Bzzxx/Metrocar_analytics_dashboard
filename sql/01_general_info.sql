-- Headline KPIs: registered users, users with a completed ride, completed rides, revenue
-- Output: data/general_info.csv
-- Expected: 17623 | 6233 | 223652 | 4251667.61

SELECT
    (SELECT COUNT(DISTINCT user_id) FROM signups)                          AS registered_users,
    (SELECT COUNT(DISTINCT user_id) FROM ride_requests
      WHERE dropoff_ts IS NOT NULL)                                        AS completed_users,
    (SELECT COUNT(*) FROM ride_requests WHERE dropoff_ts IS NOT NULL)      AS completed_rides,
    (SELECT ROUND(SUM(purchase_amount_usd)::numeric, 2) FROM transactions
      WHERE charge_status = 'Approved')                                    AS total_revenue;
