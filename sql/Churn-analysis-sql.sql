Select * from users;
SELECT * From engagement;
SELECT * FROM transactions;

-- checking total numbers of users and min and max signup dates.
Select 
count(*) as total_users,
min(signup_date) as earliest_signup,
max(signup_date) as latest_signup,
count(CASE WHEN churn_label = 1 THEN 1 END) AS churned_users
FROM users;

--calculating total failed and success
SELECT 
  transaction_status,
count(*) as total
FROM transactions
GROUP BY transaction_status
ORDER BY total DESC;

-- checking for null values
Select
 count(*) as total,
 count(failure_reason) as has_failure_reason,
 count (retry_attempted) as has_retry_data
FROM transactions
WHERE transaction_status != 'success';

--checking if every  users have engagement record
Select 
  count(distinct  u.user_id) as users,
  count(distinct  e.user_id) as users_with_engagement
FROM users u
LEFT JOIN engagement e ON u.user_id = e.user_id;


-- CHURN ANALYSIS

--Do users who experienced at least one failed transaction in Month 1 churn at a higher rate than users who never had a failure?
SELECT
  has_failed_txn,
  COUNT(*) AS total_users,
  SUM(churn_label) AS churned,
  ROUND(100.0 * SUM(churn_label) / COUNT(*), 2) AS churn_rate_pct
FROM (
  SELECT
    u.user_id,
    u.churn_label,
    -- Flag: did this user have ANY failed transaction in Month 1?
    MAX(CASE 
      WHEN t.transaction_status = 'Failed'
      AND t.transaction_date BETWEEN u.signup_date 
                             AND (u.signup_date + INTERVAL '30 days')
      THEN 1 ELSE 0 
    END) AS has_failed_txn
  FROM users u
  LEFT JOIN transactions t ON u.user_id = t.user_id
  GROUP BY u.user_id, u.churn_label
) subquery
GROUP BY has_failed_txn;


-- identifying the failure reasons
SELECT
  failure_reason,
  COUNT(DISTINCT t.user_id) AS affected_users,
  SUM(u.churn_label) AS churned,
  ROUND(100.0 * SUM(u.churn_label) / COUNT(DISTINCT t.user_id), 2) AS churn_rate_pct
FROM transactions t
JOIN users u ON t.user_id = u.user_id
WHERE t.transaction_status = 'Failed'
GROUP BY failure_reason
ORDER BY churned DESC;

-- testing retry logic
SELECT
  retry_attempted,
  retry_status,
  COUNT(*) AS transactions,
  COUNT(DISTINCT user_id) AS users
FROM transactions
WHERE transaction_status = 'Failed'
AND failure_reason = 'Gateway Error'
GROUP BY retry_attempted, retry_status
ORDER BY retry_attempted;