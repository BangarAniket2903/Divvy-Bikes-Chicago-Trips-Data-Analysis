/*******************************************************************************************
OBJECTIVE:
Analyze behavioral differences between Casual Riders and Annual Members using SQL
on Amazon Athena. The insights generated from this analysis support business
recommendations aimed at converting casual riders into annual members.

PLATFORM:
Amazon Athena (Presto SQL)

TABLE:
bike_clean
*******************************************************************************************/
/*******************************************************************************************
CHAPTER 0: DATA EXPLORATION

BUSINESS QUESTION:
What does the cleaned dataset look like before analysis begins?
*******************************************************************************************/

-- Query 0.1: Preview the cleaned dataset

SELECT *
FROM bike_clean
LIMIT 5;

/*******************************************************************************************
CHAPTER 1: WHO ARE THE RIDERS?

OBJECTIVE:
Understand the overall composition of riders and compare ride duration behavior
between Casual Riders and Annual Members.
*******************************************************************************************/

-- Query 1.1
-- Calculate total rides and percentage contribution by rider type.

SELECT
user_type,
COUNT(*) AS total_rides,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM bike_clean
GROUP BY user_type
ORDER BY total_rides DESC;

-- Query 1.2
-- Compare ride duration statistics for each rider type.

SELECT
user_type,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins,
ROUND(MIN(ride_length_mins), 2) AS min_ride_mins,
ROUND(MAX(ride_length_mins), 2) AS max_ride_mins,
ROUND(approx_percentile(ride_length_mins, 0.5), 2) AS median_ride_mins,
COUNT(*) AS total_rides
FROM bike_clean
GROUP BY user_type
ORDER BY user_type;

-- Query 1.3
-- Compare weekday versus weekend riding behavior by rider type.

SELECT
user_type,
day_type,
COUNT(*) AS total_rides,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (PARTITION BY user_type),
2
) AS percentage,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins
FROM bike_clean
GROUP BY user_type, day_type
ORDER BY user_type, day_type;

/*******************************************************************************************
CHAPTER 2: WHEN DO THEY RIDE?

OBJECTIVE:
Analyze riding behavior across weekdays and ride duration categories.
*******************************************************************************************/

-- Query 2.1
-- Identify the most popular days of the week for each rider type.

SELECT
user_type,
day_name,
COUNT(*) AS total_rides,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (PARTITION BY user_type),
2
) AS pct_of_user_rides
FROM bike_clean
GROUP BY user_type, day_name
ORDER BY user_type, total_rides DESC;

-- Query 2.2
-- Calculate average ride duration by day of week.

SELECT
user_type,
day_name,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins,
COUNT(*) AS total_rides
FROM bike_clean
GROUP BY user_type, day_name
ORDER BY user_type, avg_ride_mins DESC;

-- Query 2.3
-- Analyze distribution of rides across duration categories.

SELECT
user_type,
ride_length_category,
COUNT(*) AS total_rides,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (PARTITION BY user_type),
2
) AS percentage
FROM bike_clean
GROUP BY user_type, ride_length_category
ORDER BY
user_type,
CASE
WHEN ride_length_category = '0-10 mins' THEN 1
WHEN ride_length_category = '10-20 mins' THEN 2
WHEN ride_length_category = '20-30 mins' THEN 3
WHEN ride_length_category = '30-60 mins' THEN 4
WHEN ride_length_category = 'Above 60 mins' THEN 5
END;

/*******************************************************************************************
CHAPTER 3: WHAT TIME DO THEY RIDE?

OBJECTIVE:
Understand rider behavior throughout the day and identify peak riding periods.
*******************************************************************************************/

-- Query 3.1
-- Analyze ride volume by hour of day.

SELECT
user_type,
ride_hour,
COUNT(*) AS total_rides,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (PARTITION BY user_type),
2
) AS pct_of_rides,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins
FROM bike_clean
GROUP BY user_type, ride_hour
ORDER BY user_type, pct_of_rides DESC;

-- Query 3.2
-- Compare ride activity by time-of-day segments.

SELECT
user_type,
time_of_day,
COUNT(*) AS total_rides,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (PARTITION BY user_type),
2
) AS percentage,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins
FROM bike_clean
GROUP BY user_type, time_of_day
ORDER BY user_type, percentage DESC;

-- Query 3.3
-- Analyze time-of-day behavior separately for weekdays and weekends.

SELECT
user_type,
day_type,
time_of_day,
COUNT(*) AS total_rides,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins
FROM bike_clean
GROUP BY user_type, day_type, time_of_day
ORDER BY user_type, day_type, total_rides DESC;

/*******************************************************************************************
CHAPTER 4: DOES SEASON MATTER?

OBJECTIVE:
Evaluate monthly and seasonal trends in bike usage.
*******************************************************************************************/

-- Query 4.1
-- Monthly ride analysis.

SELECT
user_type,
month_name,
COUNT(*) AS total_rides,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (PARTITION BY user_type),
2
) AS pct_of_annual_rides,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins
FROM bike_clean
GROUP BY user_type, month_name
ORDER BY user_type, total_rides DESC;

-- Query 4.2
-- Seasonal ride analysis.

WITH seasonal_data AS (
SELECT
user_type,
ride_length_mins,
CASE
WHEN EXTRACT(MONTH FROM started_at) IN (12,1,2) THEN 'Winter'
WHEN EXTRACT(MONTH FROM started_at) IN (3,4,5) THEN 'Spring'
WHEN EXTRACT(MONTH FROM started_at) IN (6,7,8) THEN 'Summer'
ELSE 'Fall'
END AS season
FROM bike_clean
)

SELECT
user_type,
season,
COUNT(*) AS total_rides,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (PARTITION BY user_type),
2
) AS pct_of_annual_rides,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins
FROM seasonal_data
GROUP BY user_type, season
ORDER BY user_type, total_rides DESC;

/*******************************************************************************************
CHAPTER 5: WHAT DO THEY RIDE?

OBJECTIVE:
Analyze bicycle preferences across rider segments.
*******************************************************************************************/

-- Query 5.1
-- Ride distribution by bike type.

SELECT
user_type,
rideable_type,
COUNT(*) AS total_rides,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (PARTITION BY user_type),
2
) AS percentage,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins
FROM bike_clean
GROUP BY user_type, rideable_type
ORDER BY user_type, total_rides DESC;

-- Query 5.2
-- Duration statistics by bike type.

SELECT
user_type,
rideable_type,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins,
ROUND(MIN(ride_length_mins), 2) AS min_ride_mins,
ROUND(MAX(ride_length_mins), 2) AS max_ride_mins,
ROUND(
CAST(approx_percentile(ride_length_mins, 0.5) AS DOUBLE),
2
) AS median_ride_mins,
COUNT(*) AS total_rides
FROM bike_clean
GROUP BY user_type, rideable_type
ORDER BY user_type, avg_ride_mins DESC;

/*******************************************************************************************
CHAPTER 6: WHERE DO THEY GO?

OBJECTIVE:
Identify the most popular start and end stations for each rider segment.
*******************************************************************************************/

-- Query 6.1
-- Top start stations used by casual riders.

SELECT ...
LIMIT 10;

-- Query 6.2
-- Top start stations used by members.

SELECT ...
LIMIT 10;

-- Query 6.3
-- Top destination stations for casual riders.

SELECT ...
LIMIT 10;

-- Query 6.4
-- Top destination stations for members.

SELECT ...
LIMIT 10;

/*******************************************************************************************
CHAPTER 7: EXECUTIVE SUMMARY METRICS

OBJECTIVE:
Generate a consolidated KPI view comparing rider segments.
*******************************************************************************************/

-- Query 7.1
-- Final rider comparison summary.

SELECT
user_type,
COUNT(*) AS total_rides,
ROUND(AVG(ride_length_mins), 2) AS avg_ride_mins,
ROUND(
CAST(
approx_percentile(ride_length_mins, 0.5)
AS DOUBLE
),
2
) AS median_ride_mins,
ROUND(
100.0 * SUM(
CASE
WHEN day_type = 'Weekend' THEN 1
ELSE 0
END
) / COUNT(*),
2
) AS weekend_ride_pct,
ROUND(
100.0 * SUM(
CASE
WHEN ride_length_mins > 34.8 THEN 1
ELSE 0
END
) / COUNT(*),
2
) AS long_ride_pct
FROM bike_clean
GROUP BY user_type
ORDER BY user_type;
