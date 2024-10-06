# Foodie-Fi Case Study

## Introduction

I chose to work on the **Foodie-Fi case study** by Danny Ma because I have a deep interest in exploring how data can drive decision-making, especially in subscription-based businesses. The case study revolves around Foodie-Fi, a startup offering food-related streaming content. It combines the growing fields of streaming services and subscription models, making it a great learning opportunity for analyzing customer journeys, churn, and revenue trends.

Foodie-Fi was launched with a data-driven mindset, and this case study focuses on answering important business questions using subscription data.

## What I Learned

This case study allowed me to apply SQL to real-world business scenarios and taught me the following:

- **Customer Behavior Analysis:** I learned how to track customer journeys as they move between different subscription plans—from trial to paid, upgrades, downgrades, and cancellations.
- **Churn Analysis:** I calculated customer churn rates and explored how this impacts business growth.
- **Subscription Transitions:** I analyzed the impact of customer plan changes and how these transitions affect overall revenue.
- **Revenue and Payments Tracking:** I created payment tables to track recurring customer payments based on subscription type and duration.

## Case Study Link

If you're interested in exploring the case study in detail, you can check out the original [Foodie-Fi Case Study by Danny Ma](https://8weeksqlchallenge.com/case-study-3/).

## Available Data

### 1. `plans` Table

This table contains the different subscription plans that Foodie-Fi offers, including:

- Trial plan
- Basic monthly plan
- Pro monthly plan
- Pro annual plan
- Churn

| plan_id | plan_name     | price  |
| ------- | ------------- | ------ |
| 0       | trial         | 0      |
| 1       | basic monthly | 9.90   |
| 2       | pro monthly   | 19.90  |
| 3       | pro annual    | 199.00 |
| 4       | churn         | null   |

### 2. `subscriptions` Table

This table tracks customer subscriptions and records the date when a specific plan starts for each customer.

| customer_id | plan_id | start_date |
| ----------- | ------- | ---------- |
| 1           | 0       | 2020-08-01 |
| 1           | 1       | 2020-08-08 |
| 2           | 0       | 2020-09-20 |
| 2           | 3       | 2020-09-27 |

## Key Insights

### 1. Customer Journey

I analyzed the onboarding process for customers and their journey through various plans. This helped uncover patterns, such as the time it takes for users to upgrade to higher-tier plans or churn after trials.

### 2. Churn Rate

I calculated churn rates by tracking customers who canceled their subscriptions and analyzed the factors contributing to churn.

### 3. Revenue and Payments

I constructed a table to track customer payments based on their plan and the start date of the subscription. This helped in understanding monthly revenue streams and how different plans contribute to overall revenue.

## Conclusion

This case study provided a comprehensive learning experience, enhancing my understanding of subscription-based business models and data analysis. The skills I developed in SQL while working through this case will be invaluable as I continue to analyze real-world business data and contribute to data-driven decision-making.
