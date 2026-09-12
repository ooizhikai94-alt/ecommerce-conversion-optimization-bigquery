-- ============================================================
-- 09_opportunity_prioritization.sql
-- Enterprise E-Commerce Conversion Rate Optimization
--
-- Purpose:
--   Prioritize high-volume segments with below-benchmark
--   Product Detail → Purchase conversion.
--
-- Benchmark:
--   Overall sequential Product Detail → Purchase rate:
--   6.85%
--
-- Opportunity estimate:
--   Product-detail sessions × positive gap to benchmark.
--
-- Important:
--   This is a benchmark-equivalent opportunity estimate.
--   It does NOT represent confirmed lost customers or
--   guaranteed incremental purchases.
--
-- Analysis level:
--   Session-level
-- ============================================================


WITH session_actions AS (

  SELECT
    fullVisitorId,
    visitId,

    device.deviceCategory AS device_category,

    geoNetwork.country AS country,

    trafficSource.source AS traffic_source,
    trafficSource.medium AS traffic_medium,

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
    visitId,
    device_category,
    country,
    traffic_source,
    traffic_medium
),


segment_funnel AS (

  SELECT

    device_category,
    country,
    traffic_source,
    traffic_medium,

    COUNTIF(first_product_detail_hit IS NOT NULL)
      AS product_detail_sessions,

    COUNTIF(
      first_product_detail_hit IS NOT NULL
      AND first_add_to_cart_hit IS NOT NULL
      AND first_add_to_cart_hit > first_product_detail_hit
    ) AS ordered_add_to_cart_sessions,

    COUNTIF(
      first_product_detail_hit IS NOT NULL
      AND first_add_to_cart_hit IS NOT NULL
      AND first_checkout_hit IS NOT NULL
      AND first_add_to_cart_hit > first_product_detail_hit
      AND first_checkout_hit > first_add_to_cart_hit
    ) AS ordered_checkout_sessions,

    COUNTIF(
      first_product_detail_hit IS NOT NULL
      AND first_add_to_cart_hit IS NOT NULL
      AND first_checkout_hit IS NOT NULL
      AND first_purchase_hit IS NOT NULL
      AND first_add_to_cart_hit > first_product_detail_hit
      AND first_checkout_hit > first_add_to_cart_hit
      AND first_purchase_hit > first_checkout_hit
    ) AS ordered_purchase_sessions

  FROM
    session_actions

  GROUP BY
    device_category,
    country,
    traffic_source,
    traffic_medium
),


segment_rates AS (

  SELECT

    device_category,
    country,
    traffic_source,
    traffic_medium,

    product_detail_sessions,
    ordered_add_to_cart_sessions,
    ordered_checkout_sessions,
    ordered_purchase_sessions,

    SAFE_DIVIDE(
      ordered_purchase_sessions,
      product_detail_sessions
    ) AS detail_to_purchase_rate

  FROM
    segment_funnel

  WHERE
    product_detail_sessions >= 500
),


opportunity AS (

  SELECT

    device_category,
    country,
    traffic_source,
    traffic_medium,

    product_detail_sessions,
    ordered_add_to_cart_sessions,
    ordered_checkout_sessions,
    ordered_purchase_sessions,

    detail_to_purchase_rate,

    -- Overall project benchmark.
    0.0685 AS benchmark_rate,

    -- Gap between benchmark and segment performance.
    GREATEST(
      0.0685 - detail_to_purchase_rate,
      0
    ) AS benchmark_gap,

    -- Estimated additional purchases if the segment
    -- performed at the benchmark rate.
    product_detail_sessions *
    GREATEST(
      0.0685 - detail_to_purchase_rate,
      0
    ) AS benchmark_gap_sessions

  FROM
    segment_rates
)


SELECT

  device_category,
  country,
  traffic_source,
  traffic_medium,

  product_detail_sessions,
  ordered_add_to_cart_sessions,
  ordered_checkout_sessions,
  ordered_purchase_sessions,

  detail_to_purchase_rate,

  benchmark_rate,

  benchmark_gap,

  ROUND(
    benchmark_gap * 100,
    2
  ) AS benchmark_gap_percentage_points,

  ROUND(
    benchmark_gap_sessions,
    0
  ) AS benchmark_equivalent_opportunity

FROM
  opportunity

WHERE
  benchmark_gap > 0

ORDER BY
  benchmark_equivalent_opportunity DESC;
