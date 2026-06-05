-- ====================================================================
-- PROJECT: Advanced Sales Performance & Profitability Analysis
-- TECH STACK: MySQL (Joins, CTEs, Window Functions, Date Formatting)
-- AUTHOR: Ajith cb
-- ====================================================================

-- QUESTION 1: What is our month-over-month revenue growth?
-- Demonstrates: MySQL DATE_FORMAT, CTEs, and LAG Window Functions
WITH MonthlySales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m-01') AS sales_month,
        SUM(sales_amount) AS current_month_revenue
    FROM company_sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
)
SELECT 
    sales_month,
    current_month_revenue,
    LAG(current_month_revenue, 1) OVER (ORDER BY sales_month) AS previous_month_revenue,
    ROUND(
        ((current_month_revenue - LAG(current_month_revenue, 1) OVER (ORDER BY sales_month)) / 
        LAG(current_month_revenue, 1) OVER (ORDER BY sales_month)) * 100, 2
    ) AS mom_growth_percentage
FROM MonthlySales;


-- QUESTION 2: Who are our top 3 highest-spending customers in each region?
-- Demonstrates: MySQL DENSE_RANK() Partitioning
WITH RankedCustomers AS (
    SELECT 
        region,
        customer_id,
        SUM(sales_amount) AS total_spent,
        DENSE_RANK() OVER (PARTITION BY region ORDER BY SUM(sales_amount) DESC) AS customer_rank
    FROM company_sales
    GROUP BY region, customer_id
)
SELECT 
    region,
    customer_id,
    total_spent
FROM RankedCustomers
WHERE customer_rank <= 3;


-- QUESTION 3: Which product categories have lower-than-average profit margins?
-- Demonstrates: MySQL Subqueries and HAVING filters
SELECT 
    product_category,
    ROUND(SUM(profit_amount) / SUM(sales_amount) * 100, 2) AS category_profit_margin
FROM company_sales
GROUP BY product_category
HAVING SUM(profit_amount) / SUM(sales_amount) < (
    SELECT SUM(profit_amount) / SUM(sales_amount) FROM company_sales
)
ORDER BY category_profit_margin ASC;
