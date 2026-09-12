# Findings of the analysis // i used the sql to narrow down the dataset and get the funnel analysis

## Executive Summary

The primary funnel analyzed is:

Product Detail → Add to Cart → Checkout → Purchase

Across 902,755 sessions, 124,053 sessions reached a product-detail view. Of these, 42,502 progressed sequentially to add to cart, 16,215 reached checkout, and 8,500 completed a purchase.

The overall Product Detail → Purchase conversion rate was approximately **6.85%**.

The analysis identified meaningful differences across device, acquisition source, browser/operating system, geography, and combined segments.

These differences provide several areas for further CRO and technical investigation.

---

## 1. Baseline Funnel Performance

The sequential session funnel is:

| Funnel Stage | Sessions | Conversion from Previous Stage |
|---|---:|---:|
| Product Detail | 124,053 | — |
| Add to Cart | 42,502 | 34.26% |
| Checkout | 16,215 | 38.12% |
| Purchase | 8,500 | 52.42% |

Overall:

**Product Detail → Purchase = 6.85%**

### Key observation

The largest early-stage leakage occurs between:

**Product Detail → Add to Cart**

Only approximately one-third of product-detail sessions progressed to add to cart.

This makes product-detail engagement and add-to-cart behavior an important area for CRO investigation.

---

## 2. Device Performance

Device segmentation showed a substantial difference between desktop and mobile sessions.

| Device | Product Detail → Purchase |
|---|---:|
| Desktop | 8.19% |
| Tablet | 3.16% |
| Mobile | 2.46% |

Desktop sessions converted substantially better than mobile sessions.

Mobile performance was also weaker across the individual funnel transitions, rather than being isolated to a single stage.

### Interpretation

The dataset shows an association between mobile usage and lower conversion.

However, this analysis does not establish that the mobile interface itself caused the difference.

### Investigation hypothesis

The mobile journey should be investigated for:

- Product-page usability
- Add-to-cart interaction
- Page performance
- Checkout usability
- Payment flow
- Authentication/session persistence
- Mobile-specific technical issues

---

## 3. Traffic Source Performance

Traffic-source analysis showed substantial differences in conversion performance.

Selected results:

| Source / Medium | Detail → Purchase |
|---|---:|
| Direct / (none) | 9.05% |
| CPM / DFA | 7.46% |
| Google / CPC | 6.36% |
| Google / Organic | 4.19% |
| Google.com / Referral | 0.51% |
| Partners / Affiliate | 0.48% |
| YouTube.com / Referral | 0.20% |

### Key observation

Direct traffic had the strongest conversion rate among the major traffic sources.

Organic Google traffic converted materially below direct traffic.

YouTube referral traffic showed particularly weak conversion.

Affiliate traffic showed an interesting pattern: relatively strong Product Detail → Add to Cart performance but substantial downstream leakage.

### Interpretation

Traffic sources appear to bring sessions with different conversion behavior.

This could reflect differences in:

- Visitor intent
- Traffic quality
- Product/landing-page alignment
- Audience characteristics
- Checkout behavior

The dataset alone cannot determine the exact cause.

---

## 4. Device × Traffic Source

Combining device and traffic source revealed more specific patterns.

A notable comparison is:

| Segment | Detail → Purchase |
|---|---:|
| Desktop + US + Direct | 13.76% |
| Mobile + US + Direct | 4.79% |
| Desktop + US + Organic | ~7.9% |
| Mobile + US + Organic | 3.45% |

### Key observation

Within the same US traffic sources, mobile sessions converted substantially below desktop sessions.

This strengthens the case for investigating mobile-specific friction.

It does not, however, prove that device type is the causal factor.

### Additional observation

YouTube traffic performed poorly on both desktop and mobile.

This suggests that some low-conversion behavior may be associated with acquisition source rather than being purely a mobile issue.

---

## 5. Mobile Browser and Operating System

Mobile browser and operating-system analysis identified a notable outlier.

| Browser / OS | Detail → Purchase | Checkout → Purchase |
|---|---:|---:|
| Chrome / iOS | 4.01% | 42.54% |
| Safari / iOS | 2.58% | 39.08% |
| Chrome / Android | 2.43% | 30.75% |
| Android WebView / Android | 0.14% | 5.00% |

### Key observation

Android WebView sessions showed substantially lower conversion than the other major mobile browser/OS combinations.

The largest concern appears at the later checkout stage.

### Technical investigation hypothesis

Android WebView sessions warrant investigation of:

- Payment redirects
- Authentication flows
- Cookie/session persistence
- JavaScript compatibility
- Embedded-browser limitations
- Third-party payment integrations
- Checkout redirects

This is a **technical investigation hypothesis**, not evidence of a confirmed WebView defect.

---

## 6. Geographic Performance

Country-level analysis showed significant differences in funnel performance.

Selected results:

| Country | Detail → Purchase |
|---|---:|
| United States | 10.15% |
| Canada | 2.77% |
| Taiwan | 0.79% |
| Australia | 0.69% |
| United Kingdom | 0.41% |
| Japan | 0.39% |
| Germany | 0.34% |
| India | 0.16% |
| France | 0.12% |
| Italy | 0.10% |
| Netherlands | 0.19% |

The United States was the strongest major market in the analysis.

Some markets showed reasonable Product Detail → Add to Cart performance but very weak downstream conversion.

For example, India showed:

- Detail → Add to Cart: 34.50%
- Add to Cart → Checkout: 26.81%
- Checkout → Purchase: 1.75%
- Detail → Purchase: 0.16%

### Interpretation

Some geographic segments appear to experience more severe downstream funnel leakage.

Potential areas for investigation include:

- Payment methods
- Shipping availability
- Currency handling
- Localization
- Checkout requirements
- Traffic quality
- Regional product availability

The available data does not establish which factor is responsible.

---

## 7. Highest-Priority Segments

The opportunity analysis uses the overall **6.85% Detail → Purchase rate** as a benchmark.

The benchmark-equivalent opportunity is a scenario estimate:

```text
Product Detail Sessions
×
Positive Gap to 6.85% Benchmark
