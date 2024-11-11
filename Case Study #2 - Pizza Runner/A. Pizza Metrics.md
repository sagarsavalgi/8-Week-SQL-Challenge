# 🍕 Case Study #2 - Pizza Runner
## A. Pizza Metrics
### Data cleaning
  
  * Create a temporary table ```#customerorder_cleaned``` from ```customer_orders``` table:
  	* Convert ```null``` values and ```'null'``` text values in ```exclusions``` and ```extras``` into blank ```''```.
  
  ```TSQL
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
  ```
| order_id | customer_id | pizza_id | exclusions | extras | order_time           |
|----------|-------------|----------|------------|--------|-----------------------|
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02  |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52  |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23  |
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23  |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46  |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46  |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46  |
| 5        | 104         | 1        |            | 1      | 2020-01-08 21:00:29  |
| 6        | 101         | 2        |            |        | 2020-01-08 21:03:13  |
| 7        | 105         | 2        |            | 1      | 2020-01-08 21:20:29  |
| 8        | 102         | 1        |            |        | 2020-01-09 23:54:33  |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59  |
| 10       | 104         | 1        |            |        | 2020-01-11 18:34:49  |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49  |

  
  
  * Create a temporary table ```#runnerorders_cleaned``` from ```runner_orders``` table:
  	* Convert ```'null'``` text values in ```pickup_time```, ```duration``` and ```cancellation``` into ```null``` values. 
	* Cast ```pickup_time``` to DATETIME.
	* Cast ```distance``` to FLOAT.
	* Cast ```duration``` to INT.
  
  ```TSQL
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
        WHEN duration LIKE '%minute%' OR duration LIKE '%min%' THEN REPLACE(REPLACE(REPLACE(duration,'minutes',''),'mins',''),'minute','') 
        ELSE duration
      END AS INT) AS duration_in_min,
      CASE 
        WHEN cancellation IS NULL OR cancellation LIKE 'null' OR cancellation LIKE ''  THEN NULL ELSE cancellation
      END AS cancellation
 INTO
      #runnerorders_cleaned
 FROM
      pizza_runner.runner_orders;

  SELECT * FROM #runnerorders_cleaned;

```
| order_id | runner_id | pickup_time           | distance_in_km | duration_in_min | cancellation          |
|----------|-----------|-----------------------|----------------|-----------------|------------------------|
| 1        | 1         | 2020-01-01 18:15:34   | 20            | 32              | NULL                   |
| 2        | 1         | 2020-01-01 19:10:54   | 20            | 27              | NULL                   |
| 3        | 1         | 2020-01-03 00:12:37   | 13.4          | 20              | NULL                   |
| 4        | 2         | 2020-01-04 13:53:03   | 23.4          | 40              | NULL                   |
| 5        | 3         | 2020-01-08 21:10:57   | 10            | 15              | NULL                   |
| 6        | 3         | NULL                  | NULL          | NULL            | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45   | 25            | 25              | NULL                   |
| 8        | 2         | 2020-01-10 00:15:02   | 23.4          | 15              | NULL                   |
| 9        | 2         | NULL                  | NULL          | NULL            | Customer Cancellation  |
| 10       | 1         | 2020-01-11 18:50:20   | 10            | 10              | NULL                   |

  
--- 
### Q1. How many pizzas were ordered?

```TSQL
    SELECT 
        COUNT(order_id) AS totalPizzaOrdered
    FROM
        #customerorder_cleaned;
```
| totalPizzaOrdered  |
|--------------|
| 14           |

---
### Q2. How many pizzas were ordered?
```TSQL
    SELECT
        COUNT(DISTINCT(order_id)) AS uniqueOrders
    FROM
        #customerorder_cleaned;
```
|uniqueOrders|
|--------------|
| 10           |

---
### Q3. How many successful orders were delivered by each runner?
```TSQL
    SELECT 
        runner_id,
        COUNT(order_id) AS successful_deliveries
    FROM 
        #runnerorders_cleaned
    WHERE
        cancellation IS NULL
    GROUP BY
        runner_id;
```
| runner_id | successful_deliveries  |
|-----------|--------------------|
| 1         | 4                  |
| 2         | 3                  |
| 3         | 1                  |
---
### Q4. How many successful orders were delivered by each runner?

```TSQL
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
```

| pizza_name  | TypesOfPizzaDelivered |
|-------------|-----------------------|
| Meatlovers  | 9                     |
| Vegetarian  | 3                     |


---
### Q5. How many Vegetarian and Meatlovers were ordered by each customer?
```TSQL
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
```
| customer_id | Meatlovers | Vegetarian |
|-------------|------------|------------|
| 101         | 2          | 1          |
| 102         | 2          | 1          |
| 103         | 3          | 1          |
| 104         | 3          | 0          |
| 105         | 0          | 1          |

---
### Q6. What was the maximum number of pizzas delivered in a single order?
```TSQL
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
```
|order_id	|pizza_delivered_per_order|
|---------|--------------------------|
|4        |	3                        |

---
### Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```TSQL

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
```
| customer_id | change | no_change |
|-------------|--------|-----------|
| 101         | 0      | 2         |
| 102         | 0      | 3         |
| 103         | 3      | 0         |
| 104         | 2      | 1         |
| 105         | 1      | 0         |


---
### Q8. How many pizzas were delivered that had both exclusions and extras?
```TSQL
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
```
| customer_id | both_excludeextras |
|-------------|--------------------|
| 104         | 1                  |
| 105         | 0                  |
| 101         | 0                  |
| 102         | 0                  |
| 103         | 0                  |


---
### Q9. What was the total volume of pizzas ordered for each hour of the day?
```TSQL
      SELECT 
            DATEPART(HOUR, order_time) AS hour,
            COUNT(pizza_id) AS pizza_ordered
      FROM
            #customerorder_cleaned coc 
      GROUP BY
            DATEPART(HOUR, order_time);
```
| hour | pizza_ordered |
|------|---------------|
| 11   | 1             |
| 13   | 3             |
| 18   | 3             |
| 19   | 1             |
| 21   | 3             |
| 23   | 3             |


---
### Q10. What was the volume of orders for each day of the week?
```TSQL
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
 ```
| weekday   | count_per_day |
|-----------|---------------|
| Wednesday | 5             |
| Thursday  | 3             |
| Friday    | 1             |
| Saturday  | 5             |


---
My solution for **[B. Runner and Customer Experience]()**.
