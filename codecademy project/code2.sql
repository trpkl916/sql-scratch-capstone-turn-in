WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
 	'2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, first_day as month, segment,
CASE
  WHEN (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END as is_active_87,
 CASE 
  WHEN subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
END as is_canceled_87
FROM cross_join
WHERE segment=87),
status_aggregate AS
(SELECT
  month,
  SUM(is_active_87) as sum_active_87,
  SUM(is_canceled_87) as sum_canceled_87
FROM status
GROUP BY month)
SELECT 
 month,
  1.0 * sum_canceled_87/sum_active_87 AS churn_rate
FROM status_aggregate;