-- ===================================================================
-- File: 01_create_ctas_bike_clean.sql
-- Project: Divvy Bike Data Engineering Project
-- Author: Aniket Bangar
--
-- Purpose:
-- Creates a cleaned Parquet table in Athena using CTAS.
--
-- Transformations:
-- 1. Remove duplicate ride_ids
-- 2. Handle missing station names
-- 3. Calculate ride duration
-- 4. Create day, month, hour features
-- 5. Create ride duration categories
-- 6. Create time-of-day categories
-- 7. Filter invalid rides
-- ===================================================================

CREATE TABLE bike_clean
WITH (
    format = 'PARQUET',
    external_location = 's3://divvy-bikes-end-to-end-project/clean-data/'
)
AS

WITH base AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ride_id
            ORDER BY started_at
        ) AS rn,

        date_diff(
            'minute',
            started_at,
            ended_at
        ) AS ride_length_mins

    FROM raw_data
)

SELECT
    ride_id,
    rideable_type,
    started_at,
    ended_at,

    member_casual AS user_type,

    COALESCE(
        start_station_name,
        'On Street Parking'
    ) AS start_station_name,

    COALESCE(
        end_station_name,
        'On Street Parking'
    ) AS end_station_name,

    ROUND(CAST(ride_length_mins AS DOUBLE), 2)
        AS ride_length_mins,

    format_datetime(started_at, 'EEEE')
        AS day_name,

    hour(started_at)
        AS ride_hour,

    format_datetime(started_at, 'MMMM')
        AS month_name,

    CASE
        WHEN ride_length_mins < 10 THEN '0-10 mins'
        WHEN ride_length_mins < 20 THEN '10-20 mins'
        WHEN ride_length_mins < 30 THEN '20-30 mins'
        WHEN ride_length_mins < 60 THEN '30-60 mins'
        ELSE 'Above 60 mins'
    END AS ride_length_category,

    CASE
        WHEN hour(started_at) BETWEEN 5 AND 11
            THEN 'Morning'
        WHEN hour(started_at) BETWEEN 12 AND 16
            THEN 'Afternoon'
        WHEN hour(started_at) BETWEEN 17 AND 20
            THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,

    CASE
        WHEN day_of_week(started_at) IN (6, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type

FROM base

WHERE
    rn = 1
    AND ride_id IS NOT NULL
    AND started_at IS NOT NULL
    AND ended_at IS NOT NULL
    AND member_casual IN ('member', 'casual')
    AND ended_at > started_at
    AND ride_length_mins BETWEEN 1 AND 720;
