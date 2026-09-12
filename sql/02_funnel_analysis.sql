-- ============================================================
-- 02_funnel_analysis.sql
-- Enterprise E-Commerce Conversion Rate Optimization
--
-- Purpose:
--   Build a sequential session-level e-commerce funnel from
--   product detail view through purchase.
--
-- Funnel stages:
--   1. Product Detail
--   2. Add to Cart
--   3. Checkout
--   4. Purchase
--
-- Methodology:
--   A session only progresses to the next stage when the
--   corresponding action occurred AFTER the previous stage.
--
-- Important:
--   This is a session-level analysis, not a user-level analysis.
-- ============================================================


-- ------------------------------------------------------------
-- Step 1: Identify the first occurrence of each funnel action
-- within each session.
-- ------------------------------------------------------------

WITH session_actions AS (

  SELECT
    fullVisitorId,
    visitId,

    MIN(
      CASE
        WHEN hit.eCommerceAction.action_type = '2'
        THEN hit.hitNumber
      END
    ) AS first_product_detail_hit,

    MIN(
      CASE
        WHEN hit.eCommerceAction.action_type = '3'
        THEN hit.hitNumber
      END
    ) AS first_add_to_cart_hit,

    MIN(
      CASE
        WHEN hit.eCommerceAction.action_type = '5'
        THEN hit.hitNumber
      END
    ) AS first_checkout_hit,

    MIN(
      CASE
        WHEN hit.eCommerceAction.action_type = '6'
        THEN hit.hitNumber
      END
    ) AS first_purchase_hit

  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
    UNNEST(hits) AS hit

  GROUP BY
    fullVisitorId,
    visitId
),


-- ------------------------------------------------------------
-- Step 2: Apply sequential funnel logic.
--
-- A session qualifies for:
--   Add to Cart   if it occurred after Product Detail
--   Checkout     if it occurred after Add to Cart
--   Purchase     if it occurred after Checkout
-- ------------------------------------------------------------

funnel_sessions AS (

  SELECT
    fullVisitorId,
    visitId,

    first_product_detail_hit,

    CASE
      WHEN first_product_detail_hit IS NOT NULL
       AND first_add_to_cart_hit IS NOT NULL
       AND first_add_to_cart_hit > first_product_detail_hit
      THEN 1
      ELSE 0
    END AS reached_add_to_cart,

    CASE
      WHEN first_product_detail_hit IS NOT NULL
       AND first_add_to_cart_hit IS NOT NULL
       AND first_checkout_hit IS NOT NULL
       AND first_add_to_cart_hit > first_product_detail_hit
       AND first_checkout_hit > first_add_to_cart_hit
      THEN 1
      ELSE 0
    END AS reached_checkout,

    CASE
      WHEN first_product_detail_hit IS NOT NULL
       AND first_add_to_cart_hit IS NOT NULL
       AND first_checkout_hit IS NOT NULL
       AND first_purchase_hit IS NOT NULL
       AND first_add_to_cart_hit > first_product_detail_hit
       AND first_checkout_hit > first_add_to_cart_hit
       AND first_purchase_hit > first_checkout_hit
      THEN 1
      ELSE 0
    END AS reached_purchase

  FROM
    session_actions
)


-- ------------------------------------------------------------
-- Step 3: Aggregate the funnel.
-- ------------------------------------------------------------

SELECT

  COUNT(*) AS total_sessions,

  COUNTIF(first_product_detail_hit IS NOT NULL)
    AS product_detail_sessions,

  COUNTIF(reached_add_to_cart = 1)
    AS ordered_add_to_cart_sessions,

  COUNTIF(reached_checkout = 1)
    AS ordered_checkout_sessions,

  COUNTIF(reached_purchase = 1)
    AS ordered_purchase_sessions,

  SAFE_DIVIDE(
    COUNTIF(reached_add_to_cart = 1),
    COUNTIF(first_product_detail_hit IS NOT NULL)
  ) AS detail_to_cart_rate,

  SAFE_DIVIDE(
    COUNTIF(reached_checkout = 1),
    COUNTIF(reached_add_to_cart = 1)
  ) AS cart_to_checkout_rate,

  SAFE_DIVIDE(
    COUNTIF(reached_purchase = 1),
    COUNTIF(reached_checkout = 1)
  ) AS checkout_to_purchase_rate,

  SAFE_DIVIDE(
    COUNTIF(reached_purchase = 1),
    COUNTIF(first_product_detail_hit IS NOT NULL)
  ) AS detail_to_purchase_rate

FROM
  funnel_sessions;
