/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
     
     -- QUERY : 
			SELECT 
				state, COUNT(customer_id)
			FROM
				customer_t
			GROUP BY state
			ORDER BY state;
-- ---------------------------------------------------------------------------------------------------------------------------------
/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/

	-- QUERY : 
			SELECT 
				quarter_number,
				AVG(CASE
					WHEN customer_feedback = 'Very Bad' THEN 1
					WHEN customer_feedback = 'Bad' THEN 2
					WHEN customer_feedback = 'Okay' THEN 3
					WHEN customer_feedback = 'Good' THEN 4
					ELSE 5
				END) avg_rating
			FROM
				order_t
			GROUP BY quarter_number;
-- ---------------------------------------------------------------------------------------------------------------------------------
/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
		
	-- QUERY : 
        with temp2 as(
			with temp as(
				select customer_feedback,quarter_number,count(customer_feedback) as total_count  from order_t group by customer_feedback,quarter_number
                )
				select quarter_number,customer_feedback,total_count,sum(total_count) over(partition by quarter_number) total from temp
			)
            select quarter_number,customer_feedback,total_count,total,(total_count/total)*100 from temp2;
-- ---------------------------------------------------------------------------------------------------------------------------------
/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

	-- QUERY : 
		select p.vehicle_maker,count(o.customer_id)
		from product_t p join order_t o 
		on p.product_id = o.product_id
		group by p.vehicle_maker
		order by count(o.customer_id) desc limit 5;
-- ---------------------------------------------------------------------------------------------------------------------------------
/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

	 -- QUERY : 
		SELECT 
			c.state, p.vehicle_maker, COUNT(o.customer_id)
		FROM
			product_t p
				JOIN
			order_t o ON p.product_id = o.product_id
				JOIN
			customer_t c ON o.customer_id = c.customer_id
		GROUP BY c.state , p.vehicle_maker
		ORDER BY COUNT(o.customer_id) DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------
/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

	 -- QUERY : 
		SELECT 
			quarter_number, COUNT(order_id)
		FROM
			order_t
		GROUP BY quarter_number
		ORDER BY quarter_number;
-- ---------------------------------------------------------------------------------------------------------------------------------
/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.		
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
  -- QUERY : 
		With Percent_revenue_change AS
			(
			With Revenue_Diff_calc As
				(
				With Revenue_Extract As
					(
						SELECT 
							quarter_number,
							order_id,
							vehicle_price,
							quantity,
							vehicle_price * quantity AS Total_Cost
						FROM
							order_t
					)
					SELECT 
						Quarter_number,
						SUM(total_cost) AS Revenue
					FROM
						Revenue_extract
					GROUP BY quarter_number
					ORDER BY quarter_number
				)
				SELECT Quarter_number,Revenue,
				LAG(revenue) Over() AS Prev_Revenue,
				LAG(revenue) Over() - Revenue AS Diff_in_revenue	
				FROM Revenue_Diff_calc
			)
			SELECT quarter_number,Revenue,Prev_Revenue,Diff_in_Revenue,
			(Diff_in_revenue/Prev_revenue)*100 As Percent_rev
			FROM percent_revenue_change;
-- ---------------------------------------------------------------------------------------------------------------------------------
/* [Q8] What is the trend of revenue and orders by quarters?
Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

	 -- QUERY : 
		SELECT 
			Quarter_number,
			COUNT(order_id) AS Total_number_of_orders,
			SUM(vehicle_price * quantity) AS Revenue
		FROM
			order_t
		GROUP BY quarter_number
		ORDER BY quarter_number;
-- ---------------------------------------------------------------------------------------------------------------------------------
/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

	 -- QUERY : 
		SELECT 
			credit_card_type, AVG(discount)
		FROM
			customer_t c
				JOIN
			order_t o ON c.customer_id = o.customer_id
		GROUP BY c.credit_card_type;
-- ---------------------------------------------------------------------------------------------------------------------------------
/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the datediff function to find the difference between the ship date and the order date.
*/
	 -- QUERY : 
		SELECT 
			quarter_number,
			AVG(DATEDIFF(ship_date, order_date)) avg_datediff
		FROM
			order_t
		GROUP BY quarter_number
		ORDER BY quarter_number;
