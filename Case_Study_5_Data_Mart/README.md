# Case Study - Data Mart

### Author: Danny Ma

[Link to the original case study](https://8weeksqlchallenge.com/case-study-5/)

## Introduction

In an age where sustainability is a key business driver, the **Data Mart** case study caught my attention. I’ve always been interested in how business operations, particularly in retail, adapt to sustainable changes while maintaining performance. When I saw that Danny Ma’s Data Mart project needed help analyzing the impact of sustainable packaging changes on sales, I knew I wanted to dive in.

This case study focuses on analyzing sales performance for an international supermarket specializing in fresh produce, and determining how the introduction of sustainable packaging in June 2020 impacted various aspects of the business, including platforms, regions, and customer demographics.

## Why I Took On This Case Study

I wanted to better understand how significant operational changes—such as sustainability measures—affect business performance. This was a perfect opportunity to:

- Hone my SQL skills with real-world business questions.
- Practice data cleaning techniques, which are critical when working with messy, real-world data.
- Develop insights from sales trends to assess business strategies and their long-term impact.

## What I Learned

- **Data Cleansing & Transformation**: One of the most valuable aspects of this case study was transforming the data into a format ready for analysis. I worked on converting date formats, generating new columns like `age_band`, and filling in missing data, which are crucial skills when preparing data for insights.
- **Sales Analysis Before & After Change**: I got the chance to perform comparative analysis—looking at sales performance before and after the sustainable packaging changes took effect. This taught me how to quantify the impact of business decisions over time.
- **Exploring Sales by Segment**: I learned how different customer segments, regions, and platforms responded to the changes. Analyzing demographic performance was a highlight, helping me understand which groups were most affected by sustainable business practices.

- **Insights for Future Business Decisions**: The case study helped me develop recommendations for future sustainability changes. By understanding how different areas of the business were impacted, I could help design strategies that minimize disruption while promoting long-term benefits.

## Available Data

In this case study, all the data comes from a single table called `data_mart.weekly_sales`. This table captures information like sales, transactions, platforms, and customer demographics across various regions.

### Columns:

- `week_date`: Start of the sales week.
- `region`: Region where sales occurred.
- `platform`: Sales platform (Retail or Shopify).
- `segment`: Demographics segment.
- `customer_type`: Whether the customer is new or existing.
- `transactions`: Count of purchases.
- `sales`: Total dollar value of sales.

## Case Study Questions

### 1. Data Cleansing Steps

Before diving into the analysis, the data required some cleaning:

- Convert `week_date` to a date format.
- Add `week_number`, `month_number`, and `calendar_year` columns.
- Add `age_band` and `demographic` columns based on customer segments.
- Replace null values with "unknown."
- Create an `avg_transaction` column for the average transaction size.

### 2. Data Exploration

This section involves answering questions about sales and transactions across different platforms and regions:

- What is the total sales for each region each month?
- What percentage of sales come from Retail vs Shopify?
- Which customer demographics contribute the most to Retail sales?
- Is the `avg_transaction` column usable for finding the average transaction size for each year?

### 3. Before & After Analysis

A key part of the case study is comparing sales before and after the sustainability changes introduced in June 2020:

- What is the total sales for the 4 weeks before and after June 15, 2020?
- How do the metrics for the 12 weeks before and after compare to previous years (2018 and 2019)?

### 4. Bonus: Identifying the Impact Areas

In this bonus analysis, we explore which areas (regions, platforms, demographics) had the highest negative impact on sales after the changes in 2020.

## Conclusion

This case study was an insightful journey into the intersection of sustainability and business performance. Through hands-on analysis, I not only improved my SQL skills but also developed a deeper understanding of how to interpret and quantify the impact of large-scale operational changes. Going forward, this knowledge can help inform better business decisions that balance both environmental responsibility and financial success.
