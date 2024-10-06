# Case Study #4 - Data Bank

### Author: Danny Ma

[Link to the original case study](https://8weeksqlchallenge.com/case-study-4/)

## Introduction

In today’s world of digital transformation, Neo-banks are changing how we think about traditional banking by removing physical branches and going all-in on digital services. Danny Ma's "Data Bank" case study piqued my interest as it bridges the gap between financial services, cryptocurrency, and data storage in a seamless and futuristic way.

What drew me to this case study is the fascinating mix of banking, data analytics, and cloud storage — industries I’m particularly passionate about. I wanted to dive deep into the analysis to explore how digital-only banks can leverage data not only for financial services but also for innovative solutions like data storage.

This case study provided a great opportunity to challenge myself with both simple metrics and complex data allocation problems. Through analyzing customer transactions and reallocations, I could apply a mix of SQL and business logic to extract meaningful insights.

## What I Learned

- **Data Exploration**: Through analyzing the allocation of customers to nodes across different regions, I gained deeper insights into how distributed networks can reduce the risk of data theft. I calculated customer reallocations, and learned how frequent customer movement between nodes adds a layer of security to the banking system.
- **Customer Behavior Analysis**: I analyzed customer transactions to track deposits, withdrawals, and how these impact their balance. This helped me understand transaction behaviors and financial habits in the context of digital banking.
- **Data Allocation**: I explored how data storage can be provisioned in line with customer balances, testing different scenarios for monthly, average, and real-time balance calculations. This was a unique concept to me and challenged my ability to think outside the box with SQL queries.

- **Growth Metrics**: This case study provided insights into customer growth metrics, which are essential for making informed business decisions for a company like Data Bank.

## Case Study Questions

### A. Customer Nodes Exploration

1. **How many unique nodes are there on the Data Bank system?**
2. **What is the number of nodes per region?**
3. **How many customers are allocated to each region?**
4. **How many days on average are customers reallocated to a different node?**
5. **What is the median, 80th, and 95th percentile for this same reallocation days metric for each region?**

### B. Customer Transactions

1. **What is the unique count and total amount for each transaction type?**
2. **What is the average total historical deposit counts and amounts for all customers?**
3. **For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**
4. **What is the closing balance for each customer at the end of the month?**
5. **What is the percentage of customers who increase their closing balance by more than 5%?**

### C. Data Allocation Challenge

This section explores how data can be provisioned based on customer balances:

1. **Option 1**: Data is allocated based on the amount of money at the end of the previous month.
2. **Option 2**: Data is allocated on the average amount of money kept in the account over the previous 30 days.
3. **Option 3**: Data is updated in real-time.

### D. Extra Challenge

In this section, I calculated data growth using an interest rate similar to a traditional savings account. The annual interest rate was set at 6%, and I calculated daily interest on customer balances.

---

Completing this case study has been both a rewarding and challenging journey, providing valuable hands-on experience with real-world data analytics in the banking domain.
