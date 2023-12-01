# CASE STUDY 1 - DANNY’S DINER


## Table of Content
- [Project overview](#project-overview)
- [Data Source](#data-source)
- [Tools](#tools)
- [Data Cleaning](#data-cleaning)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results](#results)
- [Recommendations](#recommendations)
- [References](#references)

  
### Project overview
This Data Analysis project aims to provide hands-on experience and a deep understanding of SQL querying and manipulation of the database, to derive insights for improving the diner operations and decision-making. By analyzing the diner's data, specific business questions were addressed.


### Data Source
The dataset used for this analysis is  gotten from [here](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138), and contains information about the sales made by each customer at the Diner. 


### Tools
- MySQL - Data Analysis


### Data Cleaning
In the initial preparation of the data, the data was loaded and inspected for missing values and incorrect format and datatype. After inspecting the dataset, it was clean and needed no further cleaning.


### Exploratory Data Analysis (EDA)
It involved exploring the diner dataset to answer key questions like
- Which item on the menu is the customer's favorite?
- Who is the most valuable customer?
- Should the existing customer loyalty program be expanded?


### Data Analysis
Some interesting topics in SQL worked on in this project includes
- Common Table Expressions (CTEs)
- Ranking functions
- Case statements
- Subqueries
- Group By
- Joins

```sql
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
```

```sql
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
```


### Results
The analysis results are summarized as follows:
1. Ramen is the most popular and most purchased item among the customers.
2. Customer B frequents the diner the most, with a total of 6 visits.
3. Customer A spent the most, $76,  at the diner.
4. Customer A is the first customer to join the loyalty program.
5. Customer C is the only non-member and had the least number of visits to the diner.


### Recommendations
Based on the analysis, it is recommended that 
- More focus should be on expanding the loyalty program to Customer C, since it is the customer with the least engagement in the diner.
- The other items on the menu, Curry and sushi, should be equally promoted or substituted with items of their choices.


### References
- [Katie Huang Xiemin](https://medium.com/analytics-vidhya/8-week-sql-challenge-case-study-week-1-dannys-diner-2ba026c897ab)
- [Learning SQL_Generate, manipulate and retrieve data by Alan Beaulieu](https://www.oreilly.com/library/view/learning-sql-3rd/9781492057604/)
