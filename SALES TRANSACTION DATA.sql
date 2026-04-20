--DATA CLEANING
--Transaction Sales Rep that are not in the Sales Rep Database
SELECT 
	Count(*) AS Invalid_Count
FROM SALES_TRANSACTIONS
WHERE sales_rep_id NOT IN (SELECT sales_rep_id FROM SALES_REPS)

-- Step 2: Create an UNASSIGNED placeholder rep
IF NOT EXISTS (SELECT 1 FROM SALES_REPS WHERE sales_rep_id = 'REP-9999')
BEGIN
    INSERT INTO SALES_REPS (
        sales_rep_id, first_name, last_name, email, hire_date,
        employment_status, sales_team, territory, manager_id,
        base_salary, commission_rate, quota_annual, performance_tier
    )
    VALUES (
        'REP-9999', 'Unassigned', 'Rep', 'unassigned@company.com', GETDATE(),
        'Active', 'General', 'Unassigned', NULL,
        0, 0, 0, 'Not Applicable'
    );
END

-- Step 3: Reassign invalid transactions where sales rep id is not in  to UNASSIGNED
UPDATE SALES_TRANSACTIONS
SET sales_rep_id = 'REP-9999'
WHERE sales_rep_id NOT IN (SELECT sales_rep_id FROM SALES_REPS);

--Customers assigned to account managers that are not in the Sales Rep Database
SELECT 
    Count(*) AS Invalid_Count
    FROM CUSTOMERS
    WHERE account_manager NOT IN (SELECT sales_rep_id FROM SALES_REPS)

   --set unassigned account manager for customers with invalid account manager to null
UPDATE CUSTOMERS
SET account_manager = NULL
WHERE account_manager NOT IN (SELECT sales_rep_id FROM SALES_REPS);

   --Transactions before customer sign up date
   SELECT 
    Count(*) AS date_error_count
    FROM SALES_TRANSACTIONS st
    JOIN CUSTOMERS c ON st.customer_id = c.customer_id
    WHERE st.transaction_date < c.customer_since

    --Fix transactions with transaction date before customer sign up date by setting transaction date to customer sign up date
    UPDATE st
    SET transaction_date = c.customer_since
    FROM SALES_TRANSACTIONS st
    JOIN CUSTOMERS c ON st.customer_id = c.customer_id
    WHERE st.transaction_date < c.customer_since

    --Inactive customers with recent orders - Fix inactive customers with reccent orders
      SELECT 
   COUNT (distinct c.customer_id) AS invalid_but_Valid
    FROM CUSTOMERS c
    JOIN SALES_TRANSACTIONS st ON c.customer_id = st.customer_id
    WHERE customer_status = 'inactive'
    AND transaction_date >= '2024-01-01'

    --Update status to Active
    UPDATE c
    SET c.customer_status = 'Active'
    FROM CUSTOMERS c
    WHERE EXISTS (
    SELECT 1 FROM SALES_TRANSACTIONS t
    WHERE t.customer_id = c.customer_id
      AND t.transaction_date >= '2024-01-01'
      )
    AND c.customer_status = 'Inactive';
   
    --Overdue Pending Payment for over 90 days
      SELECT 
   COUNT (*) AS overdue_payment
    FROM SALES_TRANSACTIONS
    WHERE payment_status = 'pending'
    AND transaction_date < DATEADD(day, -90, GETDATE())


    --Update Overdue Payment to Failed
    UPDATE SALES_TRANSACTIONS
SET payment_status = 'Failed'
WHERE payment_status = 'Pending'
  AND transaction_date < DATEADD(day, -90, GETDATE());


   --Fixing Customer Missing State/Province 
   SELECT 
   COUNT (*) AS Missing_state_Count
    FROM CUSTOMERS
    WHERE state_province is Null

    -- Step 2: Populate based on city
UPDATE CUSTOMERS
SET state_province = CASE
    WHEN city = 'New York' AND country = 'USA' THEN 'New York'
    WHEN city = 'Los Angeles' AND country = 'USA' THEN 'California'
    WHEN city = 'Chicago' AND country = 'USA' THEN 'Illinois'
    WHEN city = 'Houston' AND country = 'USA' THEN 'Texas'
    WHEN city = 'Dallas' AND country = 'USA' THEN 'Texas'
    WHEN city = 'Toronto' AND country = 'Canada' THEN 'Ontario'
    WHEN city = 'Vancouver' AND country = 'Canada' THEN 'British Columbia'
    ELSE 'Unknown'
END
WHERE state_province IS NULL;

   --Customers transaction that does not exist
   SELECT 
   COUNT (*) AS Orphan_Transaction
    FROM SALES_TRANSACTIONS
    WHERE customer_id Not IN (SELECT customer_id FROM CUSTOMERS)

    --Delete Orphan Transaction
    DELETE FROM SALES_TRANSACTIONS
    WHERE customer_id Not IN (SELECT customer_id FROM CUSTOMERS


------------------------------------------------------------------------------------------------------------------

    SELECT *
    FROM SALES_TRANSACTIONS


    --How Many Revenue and Profit did we make overall
    SELECT
    COUNT(*) AS total_transactions,
    SUM(t.gross_amount) AS total_revenue,
    SUM(t.net_amount) AS total_net_revenue,
    SUM(t.net_amount - (t.quantity * p.cost_price)) AS total_profit
FROM SALES_TRANSACTIONS t
JOIN PRODUCTS p ON t.product_id = p.product_id
WHERE t.payment_status = 'Completed';


--Which Month are our best Sales
SELECT
     YEAR(transaction_date) AS Year_,
    MONTH(transaction_date) AS Month_,
    COUNT(*) AS Total_orders,
    SUM(net_amount) AS Total_Sales
    FROM SALES_TRANSACTIONS
    WHERE payment_status = 'Completed'
    GROUP BY YEAR(transaction_date), MONTH(transaction_date)
    Order By Year_ DESC, Month_ DESC

    SELECT *
    FROM CUSTOMERS

    --Top 10 customers by Revenue
    SELECT TOP 10
    c.customer_name,
    c.industry,
    COUNT(st.transaction_id) AS Total_orders,
    SUM(st.net_amount) AS Total_spent
    FROM
    CUSTOMERS c
    JOIN SALES_TRANSACTIONS st ON c.customer_id = st.customer_id
    GROUP BY c.customer_name, c.industry
    ORDER BY Total_spent DESC


        SELECT *
    FROM PRODUCTS

    --Sales by Product
        SELECT 
    p.product_name,
    p.product_category,
   COUNT(st.transaction_id) AS Times_sold,
   SUM(st.quantity) AS Unit_sold,
   SUM(st.net_amount) AS Total_Revenue
    FROM
    PRODUCTS p
    JOIN SALES_TRANSACTIONS st ON p.product_id = st.product_id
    GROUP BY p.product_name, p.product_category
    ORDER BY Total_Revenue DESC


    --Sales by Region
        SELECT 
  region,
  COUNT(*) AS Total_transaction,
  SUM(net_amount) AS Total_Revenue,
  AVG(net_amount) AS Average_transaction_size
    FROM
    SALES_TRANSACTIONS
    GROUP BY region
    ORDER BY Total_Revenue DESC


    SELECT *
    FROM SALES_REPS

--Top 10 Sales Rep by Sales
    SELECT TOP 10
    sr.first_name + ' ' + sr.last_name AS rep_name,
    sr.sales_team,
    sr.territory,
    COUNT(t.transaction_id) AS total_deals,
    SUM(t.net_amount) AS total_sales
FROM SALES_REPS sr
JOIN SALES_TRANSACTIONS t ON sr.sales_rep_id = t.sales_rep_id
WHERE t.payment_status = 'Completed'
  AND sr.employment_status = 'Active'
GROUP BY sr.first_name, sr.last_name, sr.sales_team, sr.territory
ORDER BY total_sales DESC;


--Customer who have not ordered for the past 90 days
    SELECT TOP 10
    c.customer_name,
    c.industry,
    c.customer_status,
    MAX(st.transaction_date) AS last_order_date,
    DATEDIFF(day, MAX(st.transaction_date), GETDATE())  AS days_since_order
    FROM
    CUSTOMERS c
    JOIN SALES_TRANSACTIONS st ON c.customer_id = st.customer_id
    WHERE customer_status = 'Active'
    GROUP BY c.customer_name, c.industry, c.customer_status
    HAVING DATEDIFF(day, MAX(st.transaction_date), GETDATE()) > 90
    ORDER BY days_since_order DESC 


        --Failed payment by Customers
  SELECT 
  c.customer_name,
  COUNT(*) AS Total_transaction,
  SUM(net_amount) AS Failed_Revenue
    FROM
    CUSTOMERS c
    JOIN SALES_TRANSACTIONS st ON c.customer_id = st.customer_id
    WHERE st.payment_status = 'Failed'
    GROUP BY c.customer_name
    ORDER BY Failed_Revenue DESC

    
   --Average Order Value by Customers
  SELECT 
  c.customer_name,
  c.industry,
  COUNT(st.transaction_id) AS Total_Orders,
   AVG(st.net_amount) AS Average_Order_Value,
  SUM(st.net_amount) AS Total_Revenue
    FROM
    CUSTOMERS c
    JOIN SALES_TRANSACTIONS st ON c.customer_id = st.customer_id
    WHERE st.payment_status = 'Completed'
    GROUP BY c.customer_name, c.industry
    Having COUNT(transaction_id) >= 5
    ORDER BY Average_Order_Value DESC

    
    --Sales by Payment Method
    SELECT
    payment_method,
    COUNT(*) AS transaction_count,
    SUM(net_amount) AS Total_sales,
    AVG(net_amount) AS Average
    FROM
    SALES_TRANSACTIONS
    WHERE payment_status = 'Completed'
    GROUP BY payment_method
    ORDER BY Total_sales

    --Pending Payments by Age

    SELECT
    CASE
        WHEN DATEDIFF(day, transaction_date, GETDATE()) <= 30 THEN '0-30 days'
        WHEN DATEDIFF(day, transaction_date, GETDATE()) <= 60 THEN '31-60 days'
        WHEN DATEDIFF(day, transaction_date, GETDATE()) <= 90 THEN '61-90 days'
        ELSE 'Over 90 days'
    END AS age_bucket,
    COUNT(*) AS pending_count,
    SUM(net_amount) AS pending_amount
FROM SALES_TRANSACTIONS
WHERE payment_status = 'Pending'
GROUP BY
    CASE
        WHEN DATEDIFF(day, transaction_date, GETDATE()) <= 30 THEN '0-30 days'
        WHEN DATEDIFF(day, transaction_date, GETDATE()) <= 60 THEN '31-60 days'
        WHEN DATEDIFF(day, transaction_date, GETDATE()) <= 90 THEN '61-90 days'
        ELSE 'Over 90 days'
    END
ORDER BY pending_amount DESC;


   --Sales by Industry
  SELECT 
 c.industry,
  COUNT(DISTINCT c.customer_id) AS Customer_count,
  COUNT(st.transaction_id) AS Total_Orders,
  SUM(st.net_amount) AS Total_sales
    FROM
    CUSTOMERS c
    JOIN SALES_TRANSACTIONS st ON c.customer_id = st.customer_id
    WHERE st.payment_status = 'Completed'
    GROUP BY c.industry
    ORDER BY Total_sales DESC

    --Year over year sales Comparism
        SELECT
    YEAR(transaction_date) AS Year_,
    COUNT(*) AS Total_Orders,
    SUM(net_amount) AS Total_sales,
    AVG(net_amount) AS Average_order_value
    FROM
    SALES_TRANSACTIONS
    WHERE payment_status = 'Completed'
    GROUP BY YEAR(transaction_date)
    ORDER BY Total_sales

    
        SELECT
    CASE
        WHEN discount_percent = 0 THEN 'No discount'
        WHEN discount_percent <= 10 THEN '1-10%'
        WHEN discount_percent <= 20 THEN '11-20%'
        ELSE 'Over 20%'
    END AS discount_range,
    COUNT(*) AS transaction_count,
    SUM(discount_amount) AS discount_amount_given,
    SUM(net_amount) AS Total_sales
FROM SALES_TRANSACTIONS
WHERE payment_status = 'Complete'
GROUP BY
     CASE
        WHEN discount_percent = 0 THEN 'No discount'
        WHEN discount_percent <= 10 THEN '1-10%'
        WHEN discount_percent <= 20 THEN '11-20%'
        ELSE 'Over 20%'
    END
ORDER BY Total_sales DESC;

SELECT *
FROM SALES_TARGETS

--Business Question: Which sales reps are exceeding quotas and which are underperforming?
-- Sales Rep Performance: Quota Achievement Analysis
WITH Rep_Performance AS (
    SELECT
        sr.sales_rep_id,
        sr.first_name + ' ' + sr.last_name AS rep_name,
        sr.sales_team,
        sr.territory,
        sr.performance_tier,
        SUM(st.quota_amount) AS total_quota,
        SUM(st.actual_amount) AS total_sales,
        ROUND(SUM(st.actual_amount) / NULLIF(SUM(st.quota_amount), 0) * 100, 2)
            AS quota_achievement_pct,
        COUNT(DISTINCT st.month) AS months_active,
        SUM(st.deals_closed) AS total_deals,
        AVG(st.avg_deal_size) AS avg_deal_value
    FROM SALES_REPS sr
    JOIN SALES_TARGETS st ON sr.sales_rep_id = st.sales_rep_id
    WHERE sr.employment_status = 'Active'
    GROUP BY
        sr.sales_rep_id,
        sr.first_name,
        sr.last_name,
        sr.sales_team,
        sr.territory,
        sr.performance_tier
),
Ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY quota_achievement_pct DESC) AS performance_rank,
        CASE
            WHEN quota_achievement_pct >= 120 THEN 'Exceeds Expectations'
            WHEN quota_achievement_pct >= 100 THEN 'Meets Expectations'
            WHEN quota_achievement_pct >= 80 THEN 'Close to Target'
            ELSE 'Below Target'
        END AS performance_status
    FROM Rep_Performance
)
SELECT *
FROM Ranked
ORDER BY quota_achievement_pct DESC;



--Business Question: Which products generate the most profit and which are underperforming?
-- Product Profitability: Revenue and Profit Analysis
WITH Product_Sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.product_category,
        p.product_subcategory,
        p.list_price,
        p.cost_price,
        p.profit_margin AS product_margin_pct,
        COUNT(DISTINCT t.transaction_id) AS total_transactions,
        SUM(t.quantity) AS units_sold,
        SUM(t.gross_amount) AS total_revenue,
        SUM(t.discount_amount) AS total_discounts_given,
        SUM(t.net_amount) AS total_net_revenue,
        SUM(t.quantity * p.cost_price) AS total_cost,
        SUM(t.net_amount) - SUM(t.quantity * p.cost_price) AS actual_profit
    FROM PRODUCTS p
    JOIN SALES_TRANSACTIONS t ON p.product_id = t.product_id
    WHERE t.payment_status = 'Completed'
    GROUP BY
        p.product_id,
        p.product_name,
        p.product_category,
        p.product_subcategory,
        p.list_price,
        p.cost_price,
        p.profit_margin
),
Ranked_Products AS (
    SELECT *,
        ROUND(actual_profit / NULLIF(total_net_revenue, 0) * 100, 2)
            AS realized_margin_pct,
        RANK() OVER (ORDER BY actual_profit DESC) AS profit_rank,
        RANK() OVER (ORDER BY units_sold DESC) AS volume_rank
    FROM Product_Sales
)
SELECT
    product_name,
    product_category,
    units_sold,
    total_revenue,
    total_discounts_given,
    total_net_revenue,
    total_cost,
    actual_profit,
    realized_margin_pct,
    profit_rank,
    volume_rank,
    CASE
        WHEN actual_profit < 0 THEN 'Losing Money'
        WHEN realized_margin_pct < 10 THEN 'Low Margin'
        WHEN realized_margin_pct < 30 THEN 'Healthy Margin'
        ELSE 'High Margin'
    END AS profit_status
FROM Ranked_Products
ORDER BY actual_profit DESC;

--Technical Explanation
--Joins PRODUCTS and SALES_TRANSACTIONS. Calculates actual cost and profit. realized_margin_pct shows true profit after discounts. 
--Two RANK() functions show both profit and volume rankings. Only Completed payments counted.

--Shows which products make money. Negative profit = discontinue or reprice. 
--Top 10 by profit rank deserve more marketing investment. Focus on high-margin products with decent volume.
 
--Customer Lifetime Value & Churn Risk
--Business Question: Who are our most valuable customers and which are at risk of churning?
-- Customer Lifetime Value with Churn Risk Analysis
WITH Customer_Metrics AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.industry,
        c.customer_status,
        c.customer_since,
        COUNT(DISTINCT t.transaction_id) AS total_orders,
        SUM(t.net_amount) AS lifetime_value,
        MIN(t.transaction_date) AS first_purchase,
        MAX(t.transaction_date) AS last_purchase,
        DATEDIFF(day, MAX(t.transaction_date), GETDATE()) AS days_since_last_order,
        AVG(t.net_amount) AS avg_order_value
    FROM CUSTOMERS c
    LEFT JOIN SALES_TRANSACTIONS t ON c.customer_id = t.customer_id
    WHERE t.payment_status = 'Completed' OR t.payment_status IS NULL
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.industry,
        c.customer_status,
        c.customer_since
),
CLV_Segmented AS (
    SELECT *,
        RANK() OVER (ORDER BY lifetime_value DESC) AS clv_rank,
        CASE
            WHEN lifetime_value >= 100000 THEN 'VIP'
            WHEN lifetime_value >= 50000 THEN 'High Value'
            WHEN lifetime_value >= 10000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment,
        CASE
            WHEN customer_status = 'Churned' THEN 'Already Churned'
            WHEN days_since_last_order > 180 THEN 'High Churn Risk'
            WHEN days_since_last_order > 90 THEN 'Medium Churn Risk'
            WHEN days_since_last_order > 60 THEN 'Low Churn Risk'
            ELSE 'Active'
        END AS churn_risk
    FROM Customer_Metrics
    WHERE lifetime_value > 0
)
SELECT
    customer_name,
    industry,
    customer_segment,
    lifetime_value,
    total_orders,
    avg_order_value,
    last_purchase,
    days_since_last_order,
    churn_risk,
    clv_rank
FROM CLV_Segmented
WHERE customer_segment IN ('VIP', 'High Value')
  AND churn_risk IN ('High Churn Risk', 'Medium Churn Risk')
ORDER BY lifetime_value DESC;

--Technical Explanation
--SUM(net_amount) calculates Customer Lifetime Value. DATEDIFF measures days since last purchase. 
--Multiple CASE statements segment by value and risk. WHERE filters for high-value at-risk customers needing retention focus.
--Stakeholder Explanation
--Identifies your best customers who haven't bought recently. VIP customers 180+ days = immediate outreach needed. 
--Retaining one VIP is more profitable than acquiring 10 new customers. Prioritize retention calls for high-value customers at risk.


 
--Discount Impact on Profitability
--Business Question: Are our discounts driving sales or just eroding profit margins?
-- Discount Analysis: Impact on Revenue and Profit

WITH Discount_Analysis AS (
    SELECT
        p.product_category,
        CASE
            WHEN t.discount_percent = 0 THEN 'No Discount'
            WHEN t.discount_percent <= 10 THEN '1-10%'
            WHEN t.discount_percent <= 20 THEN '11-20%'
            WHEN t.discount_percent <= 30 THEN '21-30%'
            ELSE 'Over 30%'
        END AS discount_bucket,
        COUNT(*) AS transaction_count,
        SUM(t.quantity) AS units_sold,
        SUM(t.gross_amount) AS gross_revenue,
        SUM(t.discount_amount) AS total_discount_given,
        SUM(t.net_amount) AS net_revenue,
        AVG(t.discount_percent) AS avg_discount_pct,
        SUM(t.net_amount - (t.quantity * p.cost_price)) AS profit,
        AVG(t.net_amount) AS avg_transaction_value
    FROM SALES_TRANSACTIONS t
    JOIN PRODUCTS p ON t.product_id = p.product_id
    WHERE t.payment_status = 'Completed'
    GROUP BY
        p.product_category,
        CASE
            WHEN t.discount_percent = 0 THEN 'No Discount'
            WHEN t.discount_percent <= 10 THEN '1-10%'
            WHEN t.discount_percent <= 20 THEN '11-20%'
            WHEN t.discount_percent <= 30 THEN '21-30%'
            ELSE 'Over 30%'
        END
),
ROI_Calculated AS (
    SELECT *,
        ROUND(profit / NULLIF(net_revenue, 0) * 100, 2) AS profit_margin_pct,
        ROUND(total_discount_given / NULLIF(gross_revenue, 0) * 100, 2)
            AS discount_impact_pct,
        ROUND(CAST(units_sold AS FLOAT) / NULLIF(transaction_count, 0), 2)
            AS avg_units_per_order
    FROM Discount_Analysis
)
SELECT
    product_category,
    discount_bucket,
    transaction_count,
    units_sold,
    avg_units_per_order,
    net_revenue,
    profit,
    profit_margin_pct,
    avg_discount_pct,
    total_discount_given,
    discount_impact_pct,
    avg_transaction_value
FROM ROI_Calculated
ORDER BY product_category, discount_bucket;

--Technical Explanation
--CASE buckets transactions by discount level. Calculates revenue and profit per discount tier. discount_impact_pct shows revenue given away. 
--profit_margin_pct shows realized margin after discounts. Can identify if higher discounts increase volume enough to justify margin loss.
--Stakeholder Explanation
--Shows if discounts are worth it. If margin drops from 40% to 10% with high discounts but volume only increases 20%, you're losing money. 
--Sweet spot usually 10-20% where volume increases without destroying margins. Over 30% discounts rarely pay off.
 

--Territory Performance & Growth Opportunity
--Business Question: Which territories are growing and which are stagnating?
--Territory Performance: Year-over-Year Growth Analysis
WITH Territory_Sales AS (
    SELECT
        st.territory,
        st.year,
        COUNT(DISTINCT st.sales_rep_id) AS active_reps,
        SUM(st.quota_amount) AS total_quota,
        SUM(st.actual_amount) AS total_sales,
        SUM(st.deals_closed) AS total_deals,
        AVG(st.avg_deal_size) AS avg_deal_value,
        SUM(st.new_customers) AS new_customers_acquired
    FROM SALES_TARGETS st
    JOIN SALES_REPS sr ON st.sales_rep_id = sr.sales_rep_id
    WHERE sr.employment_status = 'Active'
    GROUP BY st.territory, st.year
),
YOY_Comparison AS (
    SELECT
        territory,
        year,
        total_sales,
        total_deals,
        active_reps,
        new_customers_acquired,
        LAG(total_sales) OVER (PARTITION BY territory ORDER BY year)
            AS prev_year_sales,
        LAG(total_deals) OVER (PARTITION BY territory ORDER BY year)
            AS prev_year_deals
    FROM Territory_Sales
)
SELECT
    territory,
    year,
    total_sales,
    total_deals,
    active_reps,
    new_customers_acquired,
    prev_year_sales,
    ROUND((total_sales - prev_year_sales) / NULLIF(prev_year_sales, 0) * 100, 2)
        AS sales_growth_pct,
    ROUND((total_deals - prev_year_deals) / NULLIF(prev_year_deals, 0) * 100, 2)
        AS deals_growth_pct,
    ROUND(total_sales / NULLIF(active_reps, 0), 2) AS sales_per_rep,
    CASE
        WHEN (total_sales - prev_year_sales) / NULLIF(prev_year_sales, 0) > 0.20
            THEN 'High Growth'
        WHEN (total_sales - prev_year_sales) / NULLIF(prev_year_sales, 0) > 0.05
            THEN 'Moderate Growth'
        WHEN (total_sales - prev_year_sales) / NULLIF(prev_year_sales, 0) > -0.05
            THEN 'Flat'
        ELSE 'Declining'
    END AS growth_status
FROM YOY_Comparison
WHERE prev_year_sales IS NOT NULL
ORDER BY territory, year DESC;
--Technical Explanation
--LAG() window function with PARTITION BY territory compares each territory to itself last year. Calculates YOY growth for sales and deals. sales_per_rep shows productivity. CASE categorizes territories into growth tiers. Only includes Active reps.
--Stakeholder Explanation
--Shows which territories are winning vs losing. High-growth territories (>20%) need more reps to capitalize on momentum. Declining territories need investigation - competition, rep performance, or market saturation? Use sales_per_rep to see if growth is from hiring or better performance.
 

--Payment Risk & Cash Flow Analysis
--Business Question: Which customers represent payment risk and how much revenue is at risk?
-- Payment Risk Analysis: Collection Rates by Customer
WITH Payment_Summary AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.industry,
        c.credit_limit,
        c.payment_terms,
        COUNT(*) AS total_transactions,
        SUM(CASE WHEN t.payment_status = 'Completed' THEN t.net_amount ELSE 0 END)
            AS collected_revenue,
        SUM(CASE WHEN t.payment_status = 'Pending' THEN t.net_amount ELSE 0 END)
            AS pending_revenue,
        SUM(CASE WHEN t.payment_status = 'Failed' THEN t.net_amount ELSE 0 END)
            AS failed_revenue,
        SUM(t.net_amount) AS total_revenue,
        COUNT(CASE WHEN t.payment_status = 'Failed' THEN 1 END) AS failed_payment_count,
        MAX(CASE WHEN t.payment_status = 'Pending'
            THEN DATEDIFF(day, t.transaction_date, GETDATE()) END) AS oldest_pending_days
    FROM CUSTOMERS c
    JOIN SALES_TRANSACTIONS t ON c.customer_id = t.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.industry,
        c.credit_limit,
        c.payment_terms
),
Risk_Scored AS (
    SELECT *,
        ROUND(collected_revenue / NULLIF(total_revenue, 0) * 100, 2)
            AS collection_rate_pct,
        ROUND(failed_revenue / NULLIF(total_revenue, 0) * 100, 2)
            AS failure_rate_pct,
        ROUND(pending_revenue / NULLIF(credit_limit, 0) * 100, 2)
            AS credit_utilization_pct,
        CASE
            WHEN failed_revenue > 10000 OR (failed_revenue / NULLIF(total_revenue, 0)) > 0.10
                THEN 'High Risk'
            WHEN pending_revenue > credit_limit * 0.75
                THEN 'Credit Limit Risk'
            WHEN (failed_revenue / NULLIF(total_revenue, 0)) > 0.05
                THEN 'Medium Risk'
            WHEN oldest_pending_days > 90
                THEN 'Collection Risk'
            ELSE 'Low Risk'
        END AS risk_category,
        CASE
            WHEN (failed_revenue / NULLIF(total_revenue, 0)) > 0.10
                THEN 'Move to Prepaid Terms'
            WHEN pending_revenue > credit_limit * 0.75
                THEN 'Increase Credit Limit or Stop Orders'
            WHEN oldest_pending_days > 90
                THEN 'Escalate to Collections'
            ELSE 'Monitor'
        END AS recommended_action
    FROM Payment_Summary
)
SELECT
    customer_name,
    industry,
    payment_terms,
    credit_limit,
    total_transactions,
    total_revenue,
    collected_revenue,
    pending_revenue,
    failed_revenue,
    collection_rate_pct,
    failure_rate_pct,
    credit_utilization_pct,
    failed_payment_count,
    oldest_pending_days,
    risk_category,
    recommended_action
FROM Risk_Scored
WHERE risk_category IN ('High Risk', 'Credit Limit Risk', 'Collection Risk')
ORDER BY failed_revenue DESC, pending_revenue DESC;
--Technical Explanation
--Conditional aggregation (SUM with CASE) separates revenue by payment status. collection_rate_pct shows percentage of invoiced revenue actually collected. credit_utilization_pct shows credit limit usage. Multiple CASE conditions identify different risk types. recommended_action provides specific next steps.
--Stakeholder Explanation
--Identifies customers who aren't paying. High-risk customers with >$10K failed payments = move to prepaid immediately. Customers nearing credit limit = approve before shipping more orders. Collection-risk 90+ day pending = finance follow-up needed. Collection rate under 90% = losing 10%+ revenue to bad debt.
 
--Summary
--This document contains all 13 SQL Server queries for the sales database project:
--• 7 Data Cleaning Queries - fixing critical data quality issues
--• 21 Business Problem Queries - solving real business questions

-- queries are production-ready and optimized for Microsoft SQL Server. Each includes technical explanations for interviews and stakeholder explanations for business presentations.




