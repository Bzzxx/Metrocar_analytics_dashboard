-- Funnel conversion by age group
-- Source: funnel_analysis / raw Metrocar tables (PostgreSQL)

SELECT
  age_range,
  downloads,
  signups,
  ride_requests,
  ride_completes,
  payments,
  ROUND(100.0 * signups / NULLIF(downloads, 0), 2) AS download_to_signup_pct,
  ROUND(100.0 * ride_requests / NULLIF(signups, 0), 2) AS signup_to_request_pct,
  ROUND(100.0 * payments / NULLIF(ride_requests, 0), 2) AS request_to_payment_pct,
  ROUND(100.0 * payments / NULLIF(downloads, 0), 2) AS end_to_end_conversion_pct,
  ROUND(
    100.0 * downloads / NULLIF(SUM(downloads) OVER (), 0),
    2
  ) AS share_of_total_downloads_pct
FROM
  (
    SELECT
      age_range,
      SUM(
        CASE
          WHEN funnel_step = 1 THEN number_of_users
          ELSE 0
        END
      ) AS downloads,
      SUM(
        CASE
          WHEN funnel_step = 2 THEN number_of_users
          ELSE 0
        END
      ) AS signups,
      SUM(
        CASE
          WHEN funnel_step = 3 THEN number_of_users
          ELSE 0
        END
      ) AS ride_requests,
      SUM(
        CASE
          WHEN funnel_step = 5 THEN number_of_users
          ELSE 0
        END
      ) AS ride_completes,
      SUM(
        CASE
          WHEN funnel_step = 6 THEN number_of_users
          ELSE 0
        END
      ) AS payments
    FROM
      funnel_analysis
    WHERE
      age_range IS NOT NULL
      AND funnel_step IN (1, 2, 3, 5, 6)
    GROUP BY
      age_range
  ) t
ORDER BY
  downloads DESC;