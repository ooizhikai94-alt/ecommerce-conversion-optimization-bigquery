-- ============================================================
-- 06_mobile_browser_analysis.sql
-- Enterprise E-Commerce Conversion Rate Optimization
--
-- Purpose:
--   Investigate mobile funnel performance by browser and
--   operating system.
--
-- Funnel stages:
--   Product Detail → Add to Cart → Checkout → Purchase
--
-- Scope:
--   Mobile sessions only.
--
-- Methodology:
--   Sessions are counted only when each funnel stage occurs
--   after the preceding stage.
--
-- Important:
--   This is a session-level analysis, not a user-level analysis.
--   Browser/OS segments with small volumes should be interpreted
--   cautiously.
-- ============================================================


WITH session_actions AS (

  SELECT
    fullVisitorId,
    visitId,

    device.browser AS browser,
    device.operatingSystem AS operating_system,

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

  WHERE
    device.deviceCategory = 'mobile'

  GROUP BY
    fullVisitorId,
    visitId,
    browser,
    operating_system
),


funnel_sessions AS (

  SELECT
    browser,
    operating_system,
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


SELECT

  browser,
  operating_system,

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
  funnel_sessions

GROUP BY
  browser,
  operating_system

HAVING
  COUNTIF(first_product_detail_hit IS NOT NULL) >= 100

ORDER BY
  detail_to_purchase_rate ASC;
