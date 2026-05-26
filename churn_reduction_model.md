# Churn Reduction Model-Gateway Error Analysis

## Base Inputs

| Parameter | Value |
|-----------|-------|
| Total users in dataset | 1,000 |
| Total churned users | 350 |
| Overall churn rate | 35.0% |
| Users with gateway errors | 84 |
| Gateway error users who churned | 55 |
| Monthly subscription price | $29 |
| Average user lifetime | 3 months |

---

## Why 55 Users, Not 21

The model uses all **55 gateway error users who churned**, not just the 21 high intent users who retried manually.

This is because the model measures **immediate involuntary churn only**, not long term retention. Even a low intent user saved from a gateway failure contributes revenue for however long they stay. Every month retained is revenue recovered.

The 21 users who retried manually and still failed serve as **supporting evidence**, they confirm these are genuine motivated users,  but they are not the basis for the revenue calculation.

```
Recoverable users = gateway error users who churned = 55
```

---

## Recovery Rate Assumption

Not all 55 users will be recovered even if the gateway is fixed. Some may have churned for other reasons simultaneously.

- Industry standard for payment retry recovery: **20-40%**
- Our data shows retries succeed **27% of the time** when attempted, which sits within this range and validates the assumption

```
Users recovered = 55 × recovery rate
```

| Scenario | Recovery Rate | Users Recovered |
|----------|---------------|-----------------|
| Conservative | 20% | 11 users |
| Moderate | 30% | 17 users |
| Optimistic | 40% | 22 users |

---

## Churn Rate Reduction

```
New churn rate = (350 - users recovered) /1000 * 100
```

| Scenario | Users Saved | New Churn Rate | Reduction |
|----------|-------------|----------------|-----------|
| Baseline | — | 35.0% | — |
| Conservative | 11 | 33.9% | ↓ 1.1pp |
| Moderate | 17 | 33.3% | ↓ 1.7pp |
| Optimistic | 22 | 32.8% | ↓ 2.2pp |

> **pp = percentage points.** A drop from 35.0% to 33.3% is a 1.7 percentage point reduction in churn rate — calculated as direct subtraction between two percentages, not a relative change.

---

## Revenue Impact

```
Revenue recovered = users saved × $29 × 3 months
```

| Scenario | Users Saved | Revenue Recovered | At 1M Users (scaled) |
|----------|-------------|-------------------|----------------------|
| Conservative | 11 | $957 | ~$957K per cohort |
| Moderate | 17 | $1,479 | ~$1.47M per cohort |
| Optimistic | 22 | $1,914 | ~$1.91M per cohort |

> Numbers in the dataset column reflect this sample of 1,000 users only. Scaled figures assume proportional distribution at 1 million users.

---

## Honest Limitations

| Question | Answer |
|----------|--------|
| Does fixing the gateway guarantee long term retention? | No — users saved may still churn later for unrelated reasons |
| Are recovery rate assumptions validated by our data? | Partially — our data shows 27% retry success rate when attempted |
| Is retry currently automatic or user driven? | Needs confirmation from engineering team |

> This model estimates **immediate involuntary churn reduction only**. Revenue impact should be treated as a floor estimate, not a guarantee. The 27% observed retry success rate from our own data partially validates the recovery rate assumption and places it within industry standard range of 20–40%.
