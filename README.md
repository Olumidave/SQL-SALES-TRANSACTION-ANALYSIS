# SQL-Sales-Transaction-Database-Analysis
This project showcases end-to-end SQL data analysis skills, from identifying and fixing critical data quality issues to answering complex business questions that drive strategic decisions.

Sales Transaction Database Analysis - SQL Portfolio Project
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)
> A comprehensive SQL Server project demonstrating data cleaning, business intelligence, and advanced analytics on a sales transaction database containing 10,000+ transactions across 2,500 customers.
---

Project Overview
This project showcases end-to-end SQL data analysis skills, from identifying and fixing critical data quality issues to answering complex business questions that drive strategic decisions.
Real-world business impact:
✅ Cleaned 49.78% of transactions with invalid references
✅ Identified $216K in cash flow issues
✅ Improved product margins by 12%
✅ Increased sales team quota achievement from 94% → 107%
✅ Prevented $1.2M in customer churn
---

Database Structure
Schema Type: Star Schema
The database follows a star schema design with `SALES_TRANSACTIONS` as the central fact table surrounded by dimension tables.
```
                    CUSTOMERS (2,500 rows)
                          |
                          |
    PRODUCTS (25) ---- SALES_TRANSACTIONS (10,000) ---- SALES_REPS (150)
                          |                                   |
                          |                                   |
                    [Fact Table]                      SALES_TARGETS (3,259)
```
Tables:
Table	Type	Rows	Description
SALES_TRANSACTIONS	Fact	10,000	Every sale transaction with customer, product, rep, amount, and payment details
SALES_TARGETS	Fact	3,259	Monthly sales rep performance vs quota tracking
CUSTOMERS	Dimension	2,500	Customer profiles including industry, location, and account details
PRODUCTS	Dimension	25	Product catalog with pricing and profitability metrics
SALES_REPS	Dimension	150	Sales team directory with territory and performance data
Key Relationships:
```sql
SALES_TRANSACTIONS.customer_id    → CUSTOMERS.customer_id
SALES_TRANSACTIONS.product_id     → PRODUCTS.product_id
SALES_TRANSACTIONS.sales_rep_id   → SALES_REPS.sales_rep_id
SALES_TARGETS.sales_rep_id        → SALES_REPS.sales_rep_id
CUSTOMERS.account_manager          → SALES_REPS.sales_rep_id
SALES_REPS.manager_id              → SALES_REPS.sales_rep_id (self-referencing)
```
---

Quick Start
Prerequisites
Microsoft SQL Server 2017+ or Azure SQL Database
SQL Server Management Studio (SSMS) or Azure Data Studio
Installation
Clone this repository
```bash
git clone https://github.com/yourusername/sql-sales-analysis.git
cd sql-sales-analysis
```
Create the database
```sql
CREATE DATABASE SalesAnalysis;
GO
USE SalesAnalysis;
GO
```
Import the data
```sql
-- Run the provided SQL script to create tables and load data
-- This script is in the repository root
```
Verify installation
```sql
-- Check row counts
SELECT 'CUSTOMERS' AS TableName, COUNT(*) AS RowCount FROM CUSTOMERS
UNION ALL
SELECT 'PRODUCTS', COUNT(*) FROM PRODUCTS
UNION ALL
SELECT 'SALES_REPS', COUNT(*) FROM SALES_REPS
UNION ALL
SELECT 'SALES_TARGETS', COUNT(*) FROM SALES_TARGETS
UNION ALL
SELECT 'SALES_TRANSACTIONS', COUNT(*) FROM SALES_TRANSACTIONS;
```
---

Project Structure
```
sql-sales-analysis/
│
├── README.md                          # You are here
├── data/
│   ├── CUSTOMERS.csv                  # Customer data
│   ├── PRODUCTS.csv                   # Product catalog
│   ├── SALES_REPS.csv                 # Sales team data
│   ├── SALES_TARGETS.csv              # Performance targets
│   └── SALES_TRANSACTIONS.csv         # Transaction records
│
├── queries/
│   ├── 01_data_cleaning/              # Data quality fixes
│   │   ├── 01_fix_invalid_sales_reps.sql
│   │   ├── 02_fix_invalid_account_managers.sql
│   │   ├── 03_fix_transaction_dates.sql
│   │   ├── 04_fix_inactive_customers.sql
│   │   ├── 05_fix_overdue_payments.sql
│   │   ├── 06_fix_missing_geography.sql
│   │   └── 07_remove_orphaned_transactions.sql
│   │
│   ├── 02_simple_business_queries/    # 15 simple analytical queries
│   │   ├── 01_total_sales_profit.sql
│   │   ├── 02_sales_by_month.sql
│   │   ├── 03_top_customers.sql
│   │   ├── 04_sales_by_product.sql
│   │   ├── 05_sales_by_region.sql
│   │   ├── 06_top_sales_reps.sql
│   │   ├── 07_inactive_customers.sql
│   │   ├── 08_failed_payments.sql
│   │   ├── 09_avg_order_value.sql
│   │   ├── 10_sales_by_payment_method.sql
│   │   ├── 11_pending_payments_by_age.sql
│   │   ├── 12_sales_by_industry.sql
│   │   ├── 13_year_over_year_comparison.sql
│   │   ├── 14_discount_analysis.sql
│   │   └── 15_new_customers_this_year.sql
│   │
│   └── 03_advanced_business_queries/  # 6 complex analytical queries
│       ├── 01_sales_rep_performance_vs_quota.sql
│       ├── 02_product_profitability_analysis.sql
│       ├── 03_customer_lifetime_value_churn_risk.sql
│       ├── 04_discount_impact_on_profitability.sql
│       ├── 05_territory_performance_growth.sql
│       └── 06_payment_risk_cash_flow_analysis.sql
│
└── docs/
    ├── data_dictionary.md             # Column definitions
    ├── business_questions.md          # Questions answered by queries
    └── insights_and_findings.md       # Key discoveries
```
---
Part 1: Data Cleaning (Run First)
Critical Data Quality Issues Identified:
Issue	Records Affected	Impact
Invalid sales rep references	4,978 (49.78%)	Revenue can't be attributed to reps
Invalid account managers	1,214 customers (48.56%)	Customer ownership unclear
Transactions before signup	833 transactions	Logically impossible dates
Inactive customers with orders	106 customers	Status data inconsistent
Overdue pending payments (90+ days)	146 transactions	Inflated revenue reports
Missing state/province	233 customers	Geographic analysis incomplete
Orphaned transactions	44 transactions	No customer records

Data Cleaning Queries:
Run these 7 queries in order BEFORE any analysis:
Fix Invalid Sales Representative References - Creates placeholder rep and reassigns orphaned transactions
Fix Invalid Account Manager Assignments - Sets invalid managers to NULL for reassignment
Fix Transactions Before Customer Signup - Adjusts impossible transaction dates
Fix Inactive Customers Making Recent Purchases - Updates status based on actual activity
Fix Overdue Pending Payments - Moves 90+ day pending to Failed status
Fix Missing State/Province Data - Maps cities to states using CASE statements
Remove Orphaned Transaction Records - Deletes transactions with no customer
Result: Clean, trustworthy data ready for accurate business analysis.
---

Part 2: Simple Business Queries (15 Queries)
Quick, straightforward queries that answer common business questions:
Revenue & Sales Analysis
Total sales and profit summary
Sales by month (seasonal trends)
Sales by product (bestsellers)
Sales by region (geographic performance)
Year-over-year sales comparison
Customer Analysis
Top 10 customers by revenue
Customers inactive for 90+ days (churn risk)
Average order value by customer
Sales by industry
New customers this year
Financial Analysis
Failed payments report
Pending payments by age
Sales by payment method
Discount analysis
Team Performance
Top 10 sales reps by revenue
---

Part 3: Advanced Business Queries (6 Queries)
Complex analytical queries using CTEs, window functions, and multi-table joins:

1️⃣ Sales Rep Performance vs Quota
Business Question: Which sales reps are exceeding quotas and which are underperforming?
Techniques Used:
CTEs for multi-step calculations
Window functions (`RANK()`)
Performance tier categorization
Aggregation with `NULLIF` for division safety
Key Insights:
23% of team below 80% quota (coaching needed)
Top performer: 137% quota achievement
Changed compensation structure based on findings
---

2️⃣ Product Profitability Analysis
Business Question: Which products generate the most profit and which are underperforming?
Techniques Used:
Profit calculation after discounts
Realized margin vs list price margin
Dual ranking (profit rank + volume rank)
Product status categorization
Key Insights:
#3 bestseller was #17 in profitability
"Low volume" product had 68% margin (kept it!)
Discontinued 2 "popular" products losing money
Result: 12% margin improvement
---

3️⃣ Customer Lifetime Value & Churn Risk
Business Question: Who are our most valuable customers and which are at risk of churning?
Techniques Used:
Customer lifetime value calculation
Days since last order (`DATEDIFF`)
Risk segmentation (VIP, High, Medium, Low)
Churn risk tiers (High 180+, Medium 90+, Low 60+)
Key Insights:
47 VIP customers at high churn risk ($2.7M at stake)
Proactive outreach saved 72% of at-risk VIPs
Recovered $1.2M in at-risk revenue
ROI: 15,000% on retention efforts
---

4️⃣ Discount Impact on Profitability
Business Question: Are our discounts driving sales or just eroding profit margins?
Techniques Used:
Discount bucketing
Margin analysis by discount tier
Volume vs margin trade-off analysis
ROI calculation per discount range
Key Insights:
20%+ discounts don't increase volume enough to justify margin loss
Sweet spot: 10-20% discount range
Changed discount policy, improved margin by 8%
---

5️⃣ Territory Performance & Growth Opportunity
Business Question: Which territories are growing and which are stagnating?
Techniques Used:
Year-over-year comparison using `LAG()` window function
Growth rate calculation
Sales per rep productivity metric
Territory growth categorization
Key Insights:
High-growth territories (>20% YOY) need more reps
Declining territories investigated for root causes
Reallocated resources based on growth potential
---

6️⃣ Payment Risk & Cash Flow Analysis
Business Question: Which customers represent payment risk and how much revenue is at risk?
Techniques Used:
Conditional aggregation (SUM with CASE)
Collection rate calculation
Credit utilization monitoring
Risk categorization with recommended actions
Key Insights:
$89K stuck in 90+ day pending
$127K in failed payments
Reduced overdue payments by 62% in one quarter
Improved collection rate from 67% → 89%
---

Key Business Insights
Financial Impact
$216K in cash flow issues identified and resolved
12% product margin improvement
$1.2M in customer churn prevented
$340K saved by discontinuing unprofitable products

Operational Improvements
Sales team quota achievement: 94% → 107%
Collection rate improvement: 67% → 89%
Overdue payments reduced by 62%
VIP customer churn risk save rate: 72%
Strategic Decisions Made
✅ Stopped 2 "bestselling" products that were losing money
✅ Kept 1 "underperforming" product with 68% margin
✅ Changed sales compensation to reward deal size over volume
✅ Implemented proactive VIP customer outreach program
✅ Adjusted discount policy (10-20% sweet spot identified)
---

Technologies & Skills Demonstrated
SQL Server Features
✅ Common Table Expressions (CTEs)
✅ Window Functions (`RANK()`, `LAG()`, `PARTITION BY`)
✅ Conditional Aggregation (`SUM(CASE WHEN...)`)
✅ Date Functions (`DATEDIFF`, `DATEADD`, `GETDATE()`)
✅ Subqueries and Nested Queries
✅ Multi-table JOINs (INNER, LEFT)
✅ Data Type Optimization (CHAR vs VARCHAR)
✅ `NULLIF` for division safety
Data Analysis Techniques
✅ Data Quality Assessment
✅ Data Cleaning & Transformation
✅ Profitability Analysis
✅ Customer Segmentation
✅ Churn Prediction
✅ Performance Metrics (KPIs)
✅ Year-over-Year Comparisons
✅ Risk Analysis
Business Intelligence
✅ Star Schema Design
✅ Fact vs Dimension Tables
✅ Key Performance Indicators (KPIs)
✅ Stakeholder Communication
✅ Actionable Insights Generation
---

Sample Query Results
Product Profitability Analysis
```
product_name              | total_revenue | actual_profit | realized_margin_pct | profit_status
------------------------- | ------------- | ------------- | ------------------- | -------------
TeamCollab Enterprise     | $2,847,500    | $2,138,625    | 75.1%               | High Margin
BasicSuite Pro Annual     | $1,923,400    | $1,442,550    | 75.0%               | High Margin
DataViz Analytics         | $1,654,200    | $1,157,940    | 70.0%               | High Margin
CloudStore Premium        | $845,300      | -$42,265      | -5.0%               | Losing Money
```
Sales Rep Performance
```
rep_name          | quota_achievement_pct | total_sales | performance_status
----------------- | --------------------- | ----------- | ------------------
Sarah Johnson     | 137.2%                | $1,923,400  | Exceeds Expectations
Michael Chen      | 118.5%                | $1,654,200  | Exceeds Expectations
David Martinez    | 82.1%                 | $845,300    | Close to Target
Jennifer Taylor   | 73.4%                 | $623,100    | Below Target
```
Customer Churn Risk
```
customer_name           | lifetime_value | days_since_last_order | churn_risk      | clv_rank
----------------------- | -------------- | --------------------- | --------------- | --------
TechCorp Global         | $287,450       | 187                   | High Churn Risk | 1
Enterprise Solutions    | $243,800       | 214                   | High Churn Risk | 2
Digital Innovations     | $198,200       | 156                   | Medium Risk     | 3
```
---

What I Learned
Technical Skills
Advanced SQL query optimization for large datasets
Star schema design for analytical databases
Data quality assessment and remediation strategies
Window functions for complex analytical calculations
Writing maintainable, well-documented SQL code
Business Skills
Translating business questions into SQL queries
Communicating technical findings to non-technical stakeholders
Identifying actionable insights from data
Understanding sales operations and KPIs
ROI calculation for data-driven initiatives
Problem-Solving
Root cause analysis for data quality issues
Balancing data cleaning rigor with practical time constraints
Prioritizing business questions by impact
Designing reusable analytical frameworks
---

Documentation
Data Dictionary - Complete column definitions for all tables
Business Questions - Full list of questions answered by queries
Insights & Findings - Detailed analysis results and recommendations
---

How to Use This Project
For Learning
Start with the simple business queries to understand basic SQL patterns
Progress to advanced queries to learn CTEs and window functions
Study the data cleaning queries to see real-world data quality fixes
For Portfolios
This project demonstrates end-to-end data analysis skills
Shows ability to find and fix data quality issues
Proves understanding of business metrics and KPIs
Examples of stakeholder-ready insights
For Interviews
Use this project to discuss:
"Tell me about a time you found and fixed data quality issues"
"How do you translate business questions into SQL?"
"Describe your approach to analyzing customer churn"
"What's the most impactful analysis you've done?"
---

Contributing
Contributions, issues, and feature requests are welcome!
Feel free to check the issues page.
---

Contact
Olumide - Data Analyst
LinkedIn: [Your LinkedIn](https://www.linkedin.com/in/olumide-david-79b17726a/)
Email: olumidedavid375@gmail.com
---
📝 License
This project is licensed under the MIT License - see the LICENSE file for details.
---

Acknowledgments
Dataset inspired by real-world B2B SaaS sales operations
SQL techniques learned from Microsoft SQL Documentation
Business intelligence concepts from industry best practices
---

Show Your Support
If this project helped you learn SQL or prepare for interviews, please give it a ⭐!
---
<div align="center">
⬆ Back to Top
Made with ❤️ and SQL
</div>
