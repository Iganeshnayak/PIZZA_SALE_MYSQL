-- --Q1 --retrive total number of orders placed .
SELECT 
    *
FROM
    orders;
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
-- -Q2-- - calculate the total revenue generated from pizza sales ------
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- --Q3 --identify the higest priced pizza --
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
-- --Q4 ---identify most common pizza sized ordered ---
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC; 
-- Q5--list the top 5 most ordered pizza_types along with their quantities ----
SELECT 
    pizza_types.name, SUM(order_details.quantity) as quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;
-- --Q6 -------join the nesscerry tables to find the total quantity of each pizza category orders---
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- ---Q7-DETERMINE THE DISTRUBUTION OF ORDERS BY HOURS OF THE DAY--
SELECT 
    HOUR(order_time), COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);
-- ----Q8 JOIN RELEVANT TABLES TO FIND THE CATEGORY -WISE DISTRUBUTION OF PIZZAS ---
select category ,count(name) from pizza_types group by  category ;
-- ---Q9---GROUP THE ORDERS BY DATES AND CALCULATE THE AVARAGE NUMBER OF PIZZAS ORDERS PER DAY---
SELECT 
    ROUND(AVG(quantity), 0) as avg_pizza_order_perday
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
-- ----Q10----DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE---		
	SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
--    ------Q11CALCULETE THE PERCENTAGE CONTRIBUTION OF EACH PIZZA TYPES TO TOTAL REVENUE ----
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
-- --ANALYZE THE CUMULATIVE REVENUE GENERATED OVER TIME ---
select order_date,
sum(revenue ) over(order by order_date ) as cum_revenue 
from 
(SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.order_date)AS SALES ;

-- ----DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE FOR EACH PIZZA CATEGORY --
select name ,revenue from (select category,name ,revenue ,rank()over(partition by category order by revenue desc ) as rn
from 
(select pizza_types.category ,pizza_types.name,sum((order_details.quantity) *pizzas.price) as revenue 
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details 
on order_details.pizza_id =pizzas.pizza_id 
group by pizza_types.category ,pizza_types.name ) as a )as b 
where rn <=3 ;

