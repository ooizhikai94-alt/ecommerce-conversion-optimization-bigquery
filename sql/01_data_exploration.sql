-- ============================================================
-- 01_data_exploration.sql
-- Enterprise E-Commerce Conversion Rate Optimization
--
-- Purpose:
--   Explore the Google Analytics Sample dataset and understand
--   the distribution of hit types and e-commerce actions.
--
-- Dataset:
--   bigquery-public-data.google_analytics_sample
--
-- Key eCommerce action_type values used in this project:
--   1 = Product Click
--   2 = Product Detail
--   3 = Add to Cart
--   4 = Remove from Cart
--   5 = Checkout
--   6 = Purchase
--   7 = Refund
--   8 = Checkout Option
-- ============================================================


-- ------------------------------------------------------------
-- Query 1: Distribution of hit types
--
-- Purpose:
--   Understand the types of interactions contained in the
--   clickstream data.
-- ------------------------------------------------------------

SELECT
  hit.type,
  COUNT(*) AS hits
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST(hits) AS hit
GROUP BY
  hit.type
ORDER BY
  hits DESC;


-- ------------------------------------------------------------
-- Query 2: Distribution of e-commerce actions
--
-- Purpose:
--   Identify which e-commerce actions are present in the
--   dataset and their relative frequency.
-- ------------------------------------------------------------

SELECT
  hit.eCommerceAction.action_type,
  COUNT(*) AS occurrences
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST(hits) AS hit
WHERE
  hit.eCommerceAction.action_type IS NOT NULL
GROUP BY
  hit.eCommerceAction.action_type
ORDER BY
  occurrences DESC;
