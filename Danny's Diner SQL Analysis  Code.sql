# Case Study - Danny's Diner:
# Case Study Questions-

# Q.1) What is the total amount each customer spent at the restaurant?
SELECT 
    s.Customer_id, 
    SUM(m.price) AS Total_amount
FROM
    menu m
        JOIN
    sales s ON m.product_id = s.product_id
GROUP BY 1;


# Q.2) How many days has each customer visited the restaurant?
SELECT 
    Customer_id, 
    COUNT(DISTINCT order_date) AS Customer_visited
FROM
    sales
GROUP BY 1;


# Q.3) What was the first item from the menu purchased by each customer?
WITH first_item AS (
SELECT
    s.customer_id,
    m.product_name,
    s.product_id,
    ROW_NUMBER() OVER(PARTITION BY s.customer_id) AS rnk
FROM
    sales s
JOIN
    menu m ON s.product_id = m.product_id)
    
SELECT
    Customer_id, Product_id, Product_name AS Item_name
FROM
    first_item
WHERE rnk = 1;


# Q.4) What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    m.product_name AS Item_name, 
    COUNT(s.product_id) AS No_of_times_purchased
FROM
    menu m
        JOIN
    sales s ON m.product_id = s.product_id
GROUP BY 1
ORDER BY No_of_times_purchased DESC
LIMIT 1;


# Q.5) Which item was the most popular for each customer?
WITH most_popular_item AS (
SELECT 
    s.customer_id, m.product_name,
    COUNT(s.product_id) AS No_of_orders,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY count(s.product_id) DESC) AS rnk
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY 1, 2
)

SELECT
    Customer_id, Product_name AS Item_name, No_of_orders
FROM
    most_popular_item
WHERE rnk = 1
ORDER BY 1;
    
        
# Q.6) Which item was purchased first by the customer after they became a member?
SELECT
    Customer_ID,
    Product_Name
FROM (
    select
        s.customer_id,
        n.product_name,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id) AS rnk
    from
        members m
            JOIN
        sales s ON m.customer_id = s.customer_id
            JOIN
        menu n ON n.product_id = s.product_id
    WHERE s.order_date >= m.join_date
    ) a
WHERE rnk = 1;


# Q.7) Which item was purchased just before the customer became a member?
SELECT
    Customer_ID,
    Product_Name
FROM (
    select
        s.customer_id,
        n.product_name,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id) AS rnk
    from
        members m
            JOIN
        sales s ON m.customer_id = s.customer_id
            JOIN
        menu n ON n.product_id = s.product_id
    WHERE s.order_date < m.join_date
    ) a
WHERE rnk = 1;


# Q.8) What is the total items and amount spent for each member before they became a member?
SELECT 
    m.Customer_id, 
    count(s.product_id) as Total_items, 
    SUM(n.price) AS Total_amount
FROM
    members m
        JOIN
    sales s ON m.customer_id = s.customer_id
        JOIN
    menu n ON n.product_id = s.product_id
WHERE
    s.order_date < m.join_date
GROUP BY 1
ORDER BY 1;


# Q.9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
    s.Customer_id,
    SUM(CASE
        WHEN m.product_name = 'sushi' THEN price * 20
        ELSE price * 10
    END) AS Total_points
FROM
    menu m
        JOIN
    sales s ON m.product_id = s.product_id
GROUP BY 1
ORDER BY 1;


# Q.10) In the first week after a customer joins the program (including their join date) they earn 2x points 
# on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT 
    m.Customer_id, SUM(n.price * 20) AS Total_points
FROM
    members m
        JOIN
    sales s ON m.customer_id = s.customer_id
        JOIN
    menu n ON n.product_id = s.product_id
WHERE
    s.order_date >= m.join_date
        AND MONTH(s.order_date) = 1
GROUP BY 1
ORDER BY 1;