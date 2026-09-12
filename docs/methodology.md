# Methodology ## This is the methodology of my self-made project

## 1. Project Objective

This project analyzes e-commerce clickstream data to identify conversion funnel abandonment and prioritize potential conversion rate optimization (CRO) opportunities.

The analysis focuses on the following funnel:

Product Detail → Add to Cart → Checkout → Purchase

The analysis examines funnel performance across device, traffic source, browser, operating system, geography, and combined segments.

---

## 2. Data Source

The analysis uses the Google Analytics Sample dataset available through BigQuery Public Datasets:

`bigquery-public-data.google_analytics_sample`

The analysis uses the `ga_sessions_*` tables and unnests the `hits` array to examine individual session interactions.

---

## 3. E-Commerce Funnel Definition

The funnel stages are identified using the Google Analytics e-commerce `action_type` field:

| Action Type | Funnel Meaning |
|---|---|
| 2 | Product Detail |
| 3 | Add to Cart |
| 5 | Checkout |
| 6 | Purchase |

Only these four stages are used for the primary conversion funnel.

---

## 4. Sequential Funnel Logic

A session is considered to progress through the funnel only when the next action occurs after the previous action.

For example:

- Add to Cart must occur after Product Detail.
- Checkout must occur after Add to Cart.
- Purchase must occur after Checkout.

The analysis uses the `hitNumber` field to determine the chronological order of events within a session.

This prevents a session from being counted as a successful funnel progression merely because it contains the required actions somewhere in the session.

---

## 5. Analysis Grain

The primary analysis grain is the **session**.

A session is identified using:

- `fullVisitorId`
- `visitId`

Therefore, the reported funnel metrics represent **session-level conversion behavior**, not unique-user conversion behavior.

This distinction is important because one visitor can generate multiple sessions.

---

## 6. Funnel Metrics

The primary conversion rates are calculated as:

### Detail → Add to Cart

```text
Ordered Add to Cart Sessions
÷
Product Detail Sessions
