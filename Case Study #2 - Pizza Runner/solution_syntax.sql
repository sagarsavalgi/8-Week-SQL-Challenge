                                              				/* ------------------------------
                                              				   Case Study #2 - Pizza Runner
                                              				   ------------------------------*/


-- Creator: Sagar Mallikarjun Savalgi
-- Tool used: MS SQL Server



/*---------------------------------------
        A. Pizza Metrics
----------------------------------------*/


--	1. How many pizzas were ordered?
		
		SELECT 
			COUNT(order_id) AS totalPizzaOrdered
		FROM
			#customerorder_cleaned;


--	2. How many unique customer orders were made?

		SELECT 
			COUNT(DISTINCT(order_id)) AS uniqueOrders
		FROM 
			#customerorder_cleaned;
	

--	3. How many successful orders were delivered by each runner?

		SELECT 
			runner_id,
			COUNT(order_id) AS successful_deliveries
		FROM 
			#runnerorders_cleaned
		WHERE
			cancellation IS NULL
		GROUP BY
			runner_id;


--	4. How many of each type of pizza was delivered?

	--changing column datatype from 'text' to 'nvarchar' otherwise we get an error stating text values 
	--cannot be compared or sorted.
	ALTER TABLE pizza_runner.pizza_names
	ALTER COLUMN pizza_name NVARCHAR(MAX)

		SELECT 
			pizza_name,
			COUNT(pizza_name) AS TypesOfPizzaDelivered
		FROM
			#customerorder_cleaned coc INNER JOIN pizza_runner.pizza_names pn 
			ON coc.pizza_id=pn.pizza_id INNER JOIN #runnerorders_cleaned roc
			ON coc.order_id=roc.order_id 
		WHERE 
			roc.cancellation IS NULL
		GROUP BY
			pizza_name;
			

--	5. How many Vegetarian and Meatlovers were ordered by each customer?
	
	SELECT 
		customer_id,
		SUM(CASE
			WHEN pizza_name = 'Meatlovers' THEN 1 ELSE 0
			END) AS Meatlovers,
		SUM(CASE
			WHEN pizza_name = 'Vegetarian' THEN 1 ELSE 0
			END) AS Vegetarian
	FROM
		#customerorder_cleaned coc INNER JOIN pizza_runner.pizza_names pn 
		ON coc.pizza_id=pn.pizza_id INNER JOIN #runnerorders_cleaned roc
		ON coc.order_id=roc.order_id 
	GROUP BY
		customer_id;

		
--	6. What was the maximum number of pizzas delivered in a single order?
		
	SELECT TOP 1
		coc.order_id,
		COUNT(pizza_id) AS pizza_delivered_per_order
	FROM
		#customerorder_cleaned coc INNER JOIN #runnerorders_cleaned roc ON coc.order_id=roc.order_id 
	WHERE
		cancellation IS NULL
	GROUP BY
		coc.order_id
	ORDER BY
		pizza_delivered_per_order desc;
	

--	7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

	SELECT
		customer_id,
		SUM(CASE
			WHEN exclusions != '' OR extras != '' THEN 1 ELSE 0
		END) AS change,
		SUM(CASE
			WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0
		END) AS no_change
	FROM
		#customerorder_cleaned coc INNER JOIN #runnerorders_cleaned roc ON coc.order_id=roc.order_id 
	WHERE
		cancellation IS NULL
	GROUP BY
		customer_id;


--	8. How many pizzas were delivered that had both exclusions and extras?
	
		SELECT 
			customer_id,
			SUM(CASE 
				WHEN exclusions != '' AND extras != '' THEN 1 ELSE 0
			END) AS both_excludeextras
		FROM
			#customerorder_cleaned coc INNER JOIN #runnerorders_cleaned roc ON coc.order_id=roc.order_id 
		WHERE
			cancellation IS NULL
		GROUP BY
			customer_id
		ORDER BY
			both_excludeextras desc;


--	9. What was the total volume of pizzas ordered for each hour of the day?
		
		SELECT 
			DATEPART(HOUR, order_time) AS hour,
			COUNT(pizza_id) AS pizza_ordered
		FROM
			#customerorder_cleaned coc 
		GROUP BY
			DATEPART(HOUR, order_time);


-- 10. What was the volume of orders for each day of the week?

	SELECT
		DATENAME(WEEKDAY, order_time) AS weekday,
		COUNT(pizza_id) AS count_per_day
	FROM
		#customerorder_cleaned
	GROUP BY
		DATENAME(WEEKDAY, order_time), 
		DATEPART(WEEKDAY, order_time)
	ORDER BY 
		DATEPART(WEEKDAY, order_time);


----------------------------------------------------------------------------------------------------------------------------------------------
