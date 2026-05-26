# Coursera Mobile App — Subscription Churn Analysis

## Project Background

Coursera is a leading EdTech platform operating a subscription-based mobile app at **$29/month**. Despite strong acquisition, the platform faces a significant retention problem: **35% of subscribers cancel within their first month**, and the average user stays for only 3 months — well below what a healthy SaaS or EdTech platform would expect.

This project investigates the *internal, platform-side* causes of that early churn to separate preventable losses from natural ones, and to build a business case for targeted fixes.

**Analysis covers three key areas:**

- **Payment Infrastructure:** Are technical failures silently driving users to cancel?
- **Natural vs. Preventable Churn:** Which churned users actually got their value and left satisfied — and which were failed by the platform?
- **Revenue Impact:** What is the quantified cost of inaction, and what does fixing it recover?

> SQL queries for data cleaning and exploration → `[link]`  
> Targeted business queries → `[link]`

---

## Data Structure

The analysis uses three tables from Coursera's internal database, totalling **1,000 user records** across the Month 1 cohort.

*See the ERD below for the full schema and table relationships.*

![Entity Relationship Diagram](erd_diagram.png)

> *Rendered ERD — [view interactive version here](link)*

| Table | Key Fields |
|---|---|
| **USERS** | `user_id` (PK), `signup_date`, `country`, `device_type`, `acquisition_channel`, `subscription_plan`, `churn_label`, `churn_date` |
| **TRANSACTIONS** | `transaction_id` (PK), `user_id` (FK), `transaction_status`, `failure_reason`, `retry_attempted`, `retry_status`, `amount` |
| **ENGAGEMENT** | `user_id` (PK/FK), `days_active_month1`, `courses_started`, `lessons_completed`, `last_active_date`, `platform_used` |

---

## Executive Summary

Month 1 churn is a multi-layered problem. The analysis identified several contributing factors: platform-side payment failures that go unretried, a subset of users who churned naturally after completing their goal, a broken mobile free trial experience, missing certification delivery, and a transaction failure rate nearly double the industry benchmark. Not all of these are equally recoverable — some require engineering intervention, some require product changes, and some represent expected churn that should simply be excluded from retention targets.

The most immediately actionable finding: users who hit gateway errors churned at **65.5%** — more than double the 31.6% baseline — and **44 of those users never had a retry attempted**, even though retries succeed 27% of the time when used. At scale (1M users), fixing the retry gap alone recovers approximately **$1.47M per monthly cohort** in the moderate scenario.

---

## Insights Deep Dive

### Payment Failures & Churn

- Users who experienced at least one failed transaction in Month 1 churned at **64.4%**, versus **31.6%** for users without any failures — more than double the baseline rate.
- The overall transaction failure rate was **17.5%**, significantly above the industry standard of 5–10%.
- Not all failure types are equal: **card expired** and **insufficient funds** are user-side problems the platform cannot fix. **Gateway errors** are platform-side failures — the user had a valid payment method, but the system failed them.
- 84 users hit gateway errors; 55 of those churned at **65.5%**.

### The Retry Gap

- The retry mechanism already works: **25 users were successfully recovered** through retries, with a 27% success rate — consistent with the industry standard range of 20–40%.
- However, **44 gateway error users never had a retry attempted at all** — this is the largest, most actionable gap in the entire analysis.
- 21 users retried manually and still failed, representing the highest-confidence recoverable segment: the platform failed them twice despite a valid payment method.

### Natural vs. Preventable Churn

- A segment of churned users shows high course completion rates and positive ratings — behaviorally indistinguishable from retained users. These users got the value they came for and left satisfied.
- If ~40% of churners fall into this bucket, the **recoverable churn pool is roughly 60% of the 35%** — retention efforts should be focused exclusively there, not spread across all churners.
- Limitation: completion rate alone doesn't capture user intent. Proxy signals like certificate downloads, courses enrolled, and onboarding survey data would improve segmentation in a future iteration.

### Revenue Impact Model

Using a conservative 20–40% recovery rate on gateway error users (validated against the platform's own observed 27% retry success rate):

| Scenario | Recovery Rate | Users Saved | New Churn Rate | Revenue Recovered (1M users) |
|---|---|---|---|---|
| Conservative | 20% | 11 | 33.9% | ~$957K per cohort |
| Moderate | 30% | 17 | 33.3% | ~$1.47M per cohort |
| Optimistic | 40% | 22 | 32.8% | ~$1.91M per cohort |

> Full model methodology and assumptions → [`churn_reduction_model.md`](link)

---

## Recommendations

- **Investigate the gateway retry gap with the engineering team.** 44 users hit gateway errors with no retry attempted — this is the highest-priority finding. Whether it's a missing automated retry mechanism or a configuration issue, the fix needs to be scoped with engineering before any timeline can be committed to. The retry mechanism itself already works when triggered.

- **Stop treating all churn as a single metric.** Segment churned users by completion rate and engagement before any retention intervention. Targeting satisfied completers with win-back campaigns wastes budget; focus on users who churned mid-course with no payment issue.

- **Audit the mobile free trial gap.** Play Store reviews indicate web offers a 7-day free trial while mobile requires $29 upfront — this friction likely inflates early churn before it's even measured. A product decision is needed on whether to align the mobile and web acquisition experience.

- **Monitor gateway error rate as a standalone KPI.** A 17.5% transaction failure rate is nearly double the acceptable industry ceiling. This should be tracked on a weekly dashboard with alert thresholds, not discovered during a quarterly churn analysis.

---

## Assumptions & Caveats

- **35% Month 1 churn is assumed to be above industry benchmark.** In a real project this would first be validated against historical cohort data and competitor benchmarks before any analysis begins.
- **Data integrity is assumed to be sound.** No instrumentation gaps, broken pipelines, or cross-platform ID stitching issues were audited. A real project would validate event tracking before drawing conclusions.
- **Secondary research (Play Store reviews) is directional only.** ~20–30 reviews were used to inform hypothesis generation, not as standalone evidence. Sample size is not statistically representative.
- **Seasonality is out of scope.** Twelve months of cohort data would be needed to isolate seasonal patterns from structural churn drivers.
- **External factors excluded.** Competitor pricing changes and free alternatives (e.g. YouTube) are acknowledged contributors but are outside the platform's control and therefore not addressed here.
