-- ====================================================================
-- Retail Sales Analytics - Database Schema & Analysis Queries
-- Target Database: PostgreSQL / Microsoft SQL Server
-- ====================================================================

-- 1. Table Schema Definition
CREATE TABLE retail_sales (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(25) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    ship_mode VARCHAR(20),
    customer_id VARCHAR(15),
    customer_name VARCHAR(100),
    segment VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(15),
    region VARCHAR(15),
    product_id VARCHAR(25),
    category VARCHAR(25),
    sub_category VARCHAR(25),
    product_name VARCHAR(255),
    sales NUMERIC(10, 4) NOT NULL,
    quantity INT NOT NULL,
    discount NUMERIC(4, 2) NOT NULL,
    profit NUMERIC(10, 4) NOT NULL,
    order_year INT,
    order_month INT,
    order_month_name VARCHAR(15),
    order_day INT,
    order_weekday VARCHAR(15),
    shipping_days INT,
    profit_margin NUMERIC(10, 4)
);

-- ====================================================================
-- Executive KPI Queries
-- ====================================================================

-- Total Sales, Total Profit, Total Quantity, Total Orders, Total Customers, AOV
SELECT 
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM retail_sales;

-- ====================================================================
-- Business Problem Analysis Queries
-- ====================================================================

-- Q1: Which regions generate the highest sales and profit?
SELECT 
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM retail_sales
GROUP BY region
ORDER BY total_profit DESC;

-- Q2: Which product categories & sub-categories contribute the most to revenue?
SELECT 
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM retail_sales
GROUP BY category, sub_category
ORDER BY total_sales DESC;

-- Q3: Which customer segments are most valuable?
SELECT 
    segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM retail_sales
GROUP BY segment
ORDER BY total_profit DESC;

-- Q4: How discounts affect profitability?
-- Grouping by discount ranges to see the impact on profit margin
SELECT 
    CASE 
        WHEN discount = 0 THEN '0% No Discount'
        WHEN discount > 0 AND discount <= 0.2 THEN '1% - 20% Low Discount'
        WHEN discount > 0.2 AND discount <= 0.5 THEN '21% - 50% Medium Discount'
        ELSE 'Over 50% High Discount'
    END AS discount_tier,
    COUNT(*) AS transaction_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM retail_sales
GROUP BY 
    CASE 
        WHEN discount = 0 THEN '0% No Discount'
        WHEN discount > 0 AND discount <= 0.2 THEN '1% - 20% Low Discount'
        WHEN discount > 0.2 AND discount <= 0.5 THEN '21% - 50% Medium Discount'
        ELSE 'Over 50% High Discount'
    END
ORDER BY discount_tier;

-- Q5: Which products should be promoted or discontinued?
-- Top 10 most profitable products (Promote)
SELECT 
    product_name,
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM retail_sales
GROUP BY product_name, category
ORDER BY total_profit DESC
LIMIT 10;

-- Bottom 10 least profitable products (Discontinue or Restructure)
SELECT 
    product_name,
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM retail_sales
GROUP BY product_name, category
ORDER BY total_profit ASC
LIMIT 10;

-- Q6: Seasonal sales trends (Monthly breakdown)
SELECT 
    order_year,
    order_month,
    order_month_name,
    ROUND(SUM(sales), 2) AS monthly_sales,
    ROUND(SUM(profit), 2) AS monthly_profit,
    COUNT(DISTINCT order_id) AS order_count
FROM retail_sales
GROUP BY order_year, order_month, order_month_name
ORDER BY order_year DESC, order_month DESC;
