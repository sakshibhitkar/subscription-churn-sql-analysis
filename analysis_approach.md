# Analysis Approach & Hypothesis Framework

This document covers the full analytical thinking behind the Coursera churn project — what was hypothesized, how each hypothesis was tested, what was ruled out and why, and how the five-step analysis was structured.

---

## Secondary Research — Play Store Review Analysis

Before touching the data, qualitative signals were gathered from Google Play Store reviews for the Coursera mobile app to inform and prioritize hypotheses.

- **Source:** Google Play Store user reviews
- **Sample size:** ~20–30 reviews
- **Purpose:** Directional signals only — not statistically representative. Used solely to generate and prioritize hypotheses, not as standalone evidence.

**Key themes identified:**

- Users charged but denied course access after payment failures
- Certifications not issued after course completion
- Missing mobile features vs web (bookmarking, interactive elements)
- Declining perceived course quality
- Poor refund and customer support experience
- Mobile free trial gap — web offers 7 days free, mobile requires $29 upfront

These themes directly shaped which hypotheses were worth testing quantitatively.

---

## Hypotheses

### H1 — Gateway payment failures cause recoverable churn

Users who hit gateway errors churn at 65%. Of 84 affected users, 44 never had a retry attempted — despite retries working when they were used. The hypothesis is that a missing or inconsistent automatic retry mechanism is causing involuntary, recoverable churn.

**Why this was prioritized:** Gateway errors are platform-side failures. The user had a valid payment method; the system failed them. Unlike card-expired or insufficient-funds failures, this is something the platform can actually fix.

---

### H2 — Course completion drives natural, unrecoverable churn

Some users subscribe specifically to finish one course and leave satisfied — not dissatisfied. If true, a portion of the 35% churn is expected and should not be treated as a retention problem.

**Approach:** Create two cohorts — churned users and retained users. Compare course completion rates and average content ratings across both groups.

**If H2 is true:** A segment of churned users will show high completion rates (80%+) and high ratings, similar to retained users — indicating they got the value they came for and left on their own terms.

**Business conclusion:** This portion of churn is natural and unrecoverable. If ~40% of churners fall into this bucket, the business should stop trying to retain them and redirect retention spend toward the remaining ~60% where churn is actually preventable.

**Limitation:** Completion rate alone doesn't capture intent. A career switcher and a single-skill learner behave identically post-completion but have very different long-term value. Better segmentation would use proxy signals — number of courses enrolled, certificate downloads, onboarding survey responses — to separate the two.

---

### H3 — Missing certification delivery triggers cancellation

Users who complete a course but don't receive their certificate lose the primary tangible value they paid for. This broken experience may directly cause cancellation, particularly for credential-driven subscribers.

**Why this matters:** Certifications are a core value proposition for a paid EdTech subscription. A user who finishes a course and doesn't receive their certificate has a clear, attributable reason to cancel — and it has nothing to do with content quality or pricing.

---

### Ruled out — UX and mobile experience gaps

Poor mobile UX (missing bookmarks, broken interactive elements, worse experience vs web) surfaced repeatedly in Play Store reviews but was ruled out as a primary churn driver for this analysis.

**Reasoning:** Coursera has a fully functional web platform. Users who find genuine value in the content will tolerate a subpar mobile experience — they'll switch to web. UX friction contributes to disengagement but is unlikely to be the primary cause of cancellation at the Month 1 level. It's also not directly actionable without content-level engagement data broken down by platform.

---

## Five-Step Analysis

### Step 1 — Data sanity check

Before any analysis, the data was validated for integrity: total user count, date range coverage, churn distribution, transaction status breakdown, null values in critical columns, and whether every user had a corresponding engagement record.

This step exists because any insight built on dirty or incomplete data is unreliable. Result: everything came back clean — 1,000 users, 350 churned, no missing engagement records, nulls only where expected.

---

### Step 2 — Group comparison: failed vs no failed transactions

Users were split into two groups — those who experienced at least one failed transaction in Month 1, and those who did not. Churn rate was calculated independently for each group.

The goal was to establish whether a relationship between payment failures and churn existed at all before investigating further.

**Result:** Users with failed transactions churned at **64.4%** vs **31.6%** for users without — more than double the baseline.

---

### Step 3 — Isolating failure reason

Not all payment failures are equal. Card expired and insufficient funds are user-side problems the platform cannot fix. Gateway errors are platform-side failures — the user had valid funds and a valid card, but the system failed to process the payment.

The analysis was narrowed to gateway errors specifically because these represent recoverable churn. Fixing card-expired or insufficient-funds failures through engineering isn't possible. Fixing gateway reliability is.

**Result:** 84 users hit gateway errors; 55 of those churned at **65.5%**.

---

### Step 4 — Retry analysis

The transactions table included retry data — whether a retry was attempted and whether it succeeded. This was analyzed specifically for gateway error users to understand whether the platform was already attempting to recover failed payments.

This step is critical because it moves the finding from "gateway errors cause churn" to "here is exactly where the fix needs to happen."

**Result:** 25 users were successfully recovered through retries — proving the mechanism works when triggered. But **44 users never had a retry attempted at all**. That is the most actionable gap in the entire analysis. An additional 21 users retried manually and still failed — the platform failed them twice.

---

### Step 5 — Churn reduction model

Using the gateway error findings, a three-scenario model was built to estimate how many users could be recovered if automatic retry was applied consistently, and what that would mean for churn rate and monthly revenue.

Recovery rate assumptions of 20–40% were used, partially validated by the platform's own observed 27% retry success rate — which sits within industry standard range.

This step translates the analytical finding into a business case: the number a product or engineering team actually needs to justify prioritizing a fix.

> Full model with scenario tables → [`churn_reduction_model.md`](link)

---

## Metrics Framework

**Primary KPI**

`Month 1 Churn Rate` — percentage of users who cancelled within their first month. This is the core metric the entire analysis is trying to move.

**Supporting KPIs**

| Metric | Purpose |
|---|---|
| Transaction failure rate | Established scale of the payment problem (17.5% vs 5–10% industry standard) |
| Churn rate by failure type | Isolated which failure type was actually recoverable |
| Retry success rate | Validated that the fix already works when triggered (27% observed) |
| Gateway error churn rate | Quantified the recoverable churn opportunity (65.5%) |

**Business output metric**

`Revenue Recovered` — estimated monthly revenue recaptured by reducing gateway-driven churn. Translates the analytical finding into a number a stakeholder can act on.
