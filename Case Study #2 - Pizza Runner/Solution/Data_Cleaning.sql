--			A. Pizza Metrics

--			CLEANING THE DATA 

--	First off, clean the customer_orders table, by removing the NULL and 'null' values
	DROP TABLE IF EXISTS #customerorder_cleaned;

		SELECT
			order_id,
			customer_id,
			pizza_id,
			CASE
				WHEN exclusions IS NULL OR exclusions = 'null' THEN '' ELSE exclusions
				END AS exclusions,
			CASE
				WHEN extras IS NULL OR extras = 'null' THEN '' ELSE extras
				END AS extras,
			order_time
		INTO 
			#customerorder_cleaned
		FROM
			pizza_runner.customer_orders;

	SELECT * FROM #customerorder_cleaned;










-- Cleaning the runner_orders table

	DROP TABLE IF EXISTS #runnerorders_cleaned;

		SELECT 
			order_id,
			runner_id,
			CAST(CASE
				WHEN pickup_time = 'null' THEN NULL ELSE pickup_time
				END AS DATETIME) AS pickup_time,
			CAST(CASE	
				WHEN distance = 'null' THEN NULL 
				WHEN distance LIKE '%km' THEN REPLACE(distance,'km','')
				ELSE distance 
				END AS FLOAT) AS distance_in_km,
			CAST(CASE
				WHEN duration = 'null' THEN NULL
				WHEN duration LIKE '%minute%' OR duration LIKE '%min%' 
						THEN REPLACE(REPLACE(REPLACE(duration,'minutes',''),'mins',''),'minute','') 
						ELSE duration
				END AS INT) AS duration_in_min,
			CASE 
				WHEN cancellation IS NULL OR cancellation LIKE 'null' 
				OR cancellation LIKE ''  THEN NULL ELSE cancellation
				END AS cancellation
		INTO #runnerorders_cleaned
		FROM
			pizza_runner.runner_orders;

	SELECT * FROM #runnerorders_cleaned;


------------------------------------------------------------------------------------------------------------------------------
