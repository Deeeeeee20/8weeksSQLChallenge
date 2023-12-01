/*
NOTE: 
This dataset was gotten from Danny's SQL 8 weeks challenge. 
This is my solution to the first case study - Danny's Diner.
The solution to the case study question was written with MySQL workbench.
*/


-- Creating the tables and inserting the values

CREATE TABLE sales 
(
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

CREATE TABLE menu 
(
  product_id INT,
  product_name VARCHAR(5),
  price INT
);

CREATE TABLE members 
(
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO sales VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  INSERT INTO menu VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  INSERT INTO members VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  -- CASE STUDY SOLUTIONS
  
  -- 1. What is the total amount each customer spent at the restaurant?
  
SELECT customer_id, SUM(price) Total_amount_spent
FROM menu Mu
JOIN sales S
	ON Mu.product_id = S.product_id
GROUP BY customer_id;


-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) Number_of_visited_days
FROM sales
GROUP BY customer_id;


-- 3. What was the first item from the menu purchased by each customer?

-- Using Ranking function in a subquery to get the query results
SELECT customer_id, product_name, order_date
FROM 
	(
	SELECT customer_id, product_name, order_date, 
	RANK() OVER (PARTITION BY Customer_id ORDER BY Order_date) Order_Ranking
	FROM Sales S
	JOIN menu Mu
		ON S.product_id = Mu.product_id
	) Item_Rank
WHERE Order_Ranking = 1
GROUP BY customer_id, product_name, order_date;

			-- OR (alternative way of getting the query result)

-- Using Common Table Expression to get the query result
WITH CTE_Purchase_Ranking AS
	(
    SELECT S.customer_id, product_name, order_date, RANK() OVER(PARTITION BY customer_id ORDER BY order_date) Order_ranking
    FROM sales S
    JOIN menu Mu
		ON S.product_id = Mu.product_id
	)
SELECT customer_id, product_name, order_date, Order_ranking
FROM CTE_Purchase_Ranking
-- WHERE Order_ranking = 1
GROUP BY customer_id, product_name, order_date
ORDER BY Order_ranking;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 
SELECT product_name, COUNT(S.product_id) Times_purchased
FROM menu Mu
JOIN sales S
	ON Mu.product_id = S.product_id
GROUP BY product_name
ORDER BY 2 DESC
LIMIT 1;

		-- OR (alternative way of getting the query result)

-- Using reporting function in a subquery to get the result
SELECT product_name, MAX(No_of_purchase) Most_purchased_item
FROM 
	(SELECT DISTINCT product_name, 
	COUNT(S.product_id) OVER (PARTITION BY product_name ORDER BY customer_id) No_of_purchase
	FROM Sales S
	JOIN menu Mu
		ON S.product_id = Mu.product_id
	) Count_of_purchase
GROUP BY product_name
ORDER BY 2 DESC
LIMIT 1;
    
			-- OR (alternative way of getting the query result)
    
-- Using Subqueries to get the result
SELECT product_name, COUNT(S.product_id) Times_purchased
FROM menu Mu
JOIN sales S
	ON Mu.product_id = S.product_id
GROUP BY S.product_id, product_name
HAVING COUNT(S.product_id) =
	(
    SELECT MAX(Times_purchased) Most_purchased_item
    FROM 
		(
		SELECT COUNT(product_id) Times_purchased
		FROM sales
		GROUP BY product_id
		) Number_of_purchase
	);


    
-- 5. Which item was the most popular for each customer?

-- Using Ranking function in a subquery to get the query results
SELECT customer_id, product_name, Item_Count
FROM
	(
    SELECT customer_id, product_name, COUNT(S.product_id) Item_Count,
    RANK () OVER (PARTITION BY customer_id ORDER BY COUNT(S.product_id) DESC) Item_ranking
    FROM sales S
    JOIN menu Mu
		ON Mu.product_id = S.product_id 
    GROUP BY customer_id, product_name
    ) Count_of_product
WHERE Item_ranking = 1;

		-- OR (alternative way of getting the query result)

-- Using CTE to get the result
WITH CTE_Most_Popular_Item AS
	(
    SELECT customer_id, product_name, COUNT(s.product_id) Number_of_orders, 
    RANK () OVER (PARTITION BY customer_id ORDER BY COUNT(S.product_id) DESC) Item_ranking
    FROM sales S
    JOIN menu Mu
		ON Mu.product_id = S.product_id
	GROUP BY customer_id, product_name
    )
SELECT Customer_id, product_name, Number_of_orders
FROM CTE_Most_Popular_Item
WHERE Item_ranking = 1;


-- 6. Which item was purchased first by the customer after they became a member?

WITH CTE_Purchase_Ranking AS
	(
    SELECT S.customer_id, product_name, order_date, join_date, 
    RANK() OVER(PARTITION BY customer_id ORDER BY order_date) Membership_ranking
    FROM sales S
    JOIN menu Mu
		ON S.product_id = Mu.product_id
	JOIN members Ms
		ON S.customer_id = Ms.customer_id
	WHERE order_date >= join_date
    )
SELECT DISTINCT customer_id, product_name, order_date, join_date
FROM CTE_Purchase_Ranking
WHERE Membership_ranking = 1;
    

-- 7. Which item was purchased just before the customer became a member?

WITH CTE_Purchase_Ranking AS
	(
    SELECT S.customer_id, product_name, order_date, join_date, 
    RANK() OVER(PARTITION BY customer_id ORDER BY order_date) Membership_ranking
    FROM sales S
    JOIN menu Mu
		ON S.product_id = Mu.product_id
	JOIN members Ms
		ON S.customer_id = Ms.customer_id
	WHERE join_date >= order_date
    )
SELECT DISTINCT customer_id, product_name, order_date, join_date
FROM CTE_Purchase_Ranking
WHERE Membership_ranking = 1;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT Ms.customer_id, COUNT(s.product_id) Total_item, SUM(price) Total_amount_spent
FROM sales S
JOIN members Ms
	ON S.customer_id = Ms.customer_id
JOIN menu Mu
	ON S.product_id = Mu.product_id
WHERE join_date > order_date
GROUP BY Ms.customer_id
ORDER BY 1;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH CTE_Products_points AS
	(
    SELECT S.customer_id, product_name, price,
	CASE 
		WHEN product_name = 'sushi' THEN price * 20
		ELSE price * 10
	END AS Products_points
    FROM sales S
	JOIN menu Mu
		ON S.product_id = Mu.product_id
    ) 
SELECT Customer_id, SUM(Products_points) Customer_Total_points
FROM CTE_Products_points PP
GROUP BY Customer_id;
    
    
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT customer_id, 
SUM(CASE
	WHEN order_date - join_date BETWEEN  0 AND 6 THEN price * 2 * 10
	WHEN product_name = 'sushi' THEN price * 2 * 10
    ELSE price * 10
END) total_points
FROM sales S
JOIN menu Mu USING (product_id)
JOIN members Ms USING (customer_id)
WHERE EXTRACT(MONTH FROM order_date) = 1
GROUP BY customer_id
ORDER BY 1;



		-- BONUS QUESTION
-- 1. Join all the things.
-- Recreate the table (customer_id, order_date, product_name, price, member [i.e the membership status as Y/N]) with the available data

SELECT S.customer_id, S.order_date, Mu.product_name, Mu.price,
CASE
	WHEN S.customer_id = 'A' AND S.order_date >= '2021-01-07' THEN 'Y'
	WHEN S.customer_id = 'B' AND S.order_date >= '2021-01-09' THEN 'Y'
    ELSE 'N'
END members
FROM sales S
LEFT JOIN menu Mu
	ON S.product_id = Mu.product_id
LEFT JOIN members Ms
	ON S.customer_id = Ms.customer_id; 

					-- OR (alternative way of getting the query result)

SELECT S.customer_id, S.order_date, Mu.product_name, Mu.price,
CASE
	WHEN order_date >= join_date THEN 'Y'
	WHEN order_date < join_date THEN 'N'
    ELSE 'N'
END members
FROM sales S
LEFT JOIN menu Mu
	ON S.product_id = Mu.product_id
LEFT JOIN members Ms
	ON S.customer_id = Ms.customer_id;

					-- OR (alternative way of getting the query result)

CREATE VIEW member_status AS
SELECT customer_id, order_date, product_name, price,
CASE
	WHEN order_date >= join_date THEN 'Y'
	ELSE 'N'
END members
FROM sales
LEFT JOIN menu USING (product_id)
LEFT JOIN members USING (customer_id);

SELECT *
FROM member_status;


-- 2. Ranking all the things.
-- Danny requires the ranking of the customer products, but he does not need the ranking for non-member purchases, so he expects 'null' ranking values for the records when the customers are not yet a part of the program.

WITH CTE_Members AS
(
	SELECT S.customer_id, S.order_date, Mu.product_name, Mu.price,
	CASE
		WHEN order_date >= join_date THEN 'Y'
		WHEN order_date < join_date THEN 'N'
		ELSE 'N'
	END members
	FROM sales S
	LEFT JOIN menu Mu
		ON S.product_id = Mu.product_id
	LEFT JOIN members Ms
		ON S.customer_id = Ms.customer_id
)
SELECT *,
    CASE 
		WHEN Members = 'N' THEN 'NULL'
		ELSE RANK () OVER (PARTITION BY customer_id, members ORDER BY order_date)
	END ranking
FROM CTE_Members;