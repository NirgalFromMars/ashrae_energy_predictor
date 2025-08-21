-- applying correlation among every column with meter_reading column (variable to predict) to value how independent variables explain dependent
-- variable to predict -- result: very low correlation for all columns

WITH correlations AS (
  SELECT 'square_feet_norm' AS feature, CORR(square_feet_norm, meter_reading) AS correlation FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'air_temperature_norm', CORR(air_temperature_norm, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'dew_temperature_norm', CORR(dew_temperature_norm, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'cloud_coverage_norm', CORR(cloud_coverage_norm, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'precip_depth_1_hr_norm', CORR(precip_depth_1_hr_norm, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'sea_level_pressure_norm', CORR(sea_level_pressure_norm, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'wind_direction_norm', CORR(wind_direction_norm, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'wind_speed_norm', CORR(wind_speed_norm, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'year_built', CORR(year_built, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'floor_count', CORR(floor_count, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'hour', CORR(hour, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'month', CORR(month, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'meter', CORR(meter, meter_reading) FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 
    'primary_use', 
    CORR(
      CASE primary_use
        WHEN 'Education' THEN 1
        WHEN 'Entertainment/public assembly' THEN 2
        WHEN 'Food sales and service' THEN 3
        WHEN 'Healthcare' THEN 4
        WHEN 'Lodging/residential' THEN 5
        WHEN 'Manufacturing/industrial' THEN 6
        WHEN 'Office' THEN 7
        WHEN 'Other' THEN 8
        WHEN 'Parking' THEN 9
        WHEN 'Public services' THEN 10
        WHEN 'Religious worship' THEN 11
        WHEN 'Retail' THEN 12
        WHEN 'Services' THEN 13
        WHEN 'Technology/science' THEN 14
        WHEN 'Utility' THEN 15
        WHEN 'Warehouse/storage' THEN 16
        ELSE NULL
      END, 
      meter_reading
    ) 
  FROM `ashrae_dataset.silver_norm_split`
  UNION ALL
  SELECT 'is_weekend', CORR(is_weekend, meter_reading) FROM `ashrae_dataset.silver_norm_split`
)

SELECT * FROM correlations
ORDER BY ABS(correlation) DESC;



-- generate cyclic variables from hour & month

CREATE OR REPLACE TABLE `ashrae_dataset.silver_norm_features_v1` AS
SELECT
    *,
    -- Variables cíclicas para la hora
    SIN(2 * ACOS(-1) * hour / 24) AS hour_sin,
    COS(2 * ACOS(-1) * hour / 24) AS hour_cos,

    -- Variables cíclicas para el mes
    SIN(2 * ACOS(-1) * month / 12) AS month_sin,
    COS(2 * ACOS(-1) * month / 12) AS month_cos
FROM
    `ashrae_dataset.silver_norm_split`;



-- create new variables combining some of the existing ones

CREATE OR REPLACE TABLE `ashrae_dataset.silver_norm_features_v2` AS
SELECT
    *,
    -- interaction size & temperature
    square_feet_norm * air_temperature_norm AS sqft_airtemp,

    -- interaction size & wind_speed
    square_feet_norm * wind_speed_norm AS sqft_windspeed,

    -- interaction temperature & humidity (represented by dew temp)
    air_temperature_norm * dew_temperature_norm AS temp_dewtemp,

    -- square year_built
    POW(year_built, 2) AS year_built_sq

FROM
    `ashrae_dataset.silver_norm_features_v1`;



-- calculate correlation these new columns have with objective variable "meter_reading", to value if they'll help to explain it better than others
-- results: again, low correlations for all 8 new columns created... they don't explain better the variable to predict (meter_reading)


SELECT 'hour_sin' AS feature, CORR(meter_reading, hour_sin) AS correlation
FROM `ashrae_dataset.silver_norm_features_v1`
UNION ALL
SELECT 'hour_cos' AS feature, CORR(meter_reading, hour_cos) AS correlation
FROM `ashrae_dataset.silver_norm_features_v1`
UNION ALL
SELECT 'month_sin' AS feature, CORR(meter_reading, month_sin) AS correlation
FROM `ashrae_dataset.silver_norm_features_v1`
UNION ALL
SELECT 'month_cos' AS feature, CORR(meter_reading, month_cos) AS correlation
FROM `ashrae_dataset.silver_norm_features_v1`
UNION ALL
SELECT 'sqft_airtemp' AS feature, CORR(meter_reading, sqft_airtemp) AS correlation
FROM `ashrae_dataset.silver_norm_features_v2`
UNION ALL
SELECT 'sqft_windspeed' AS feature, CORR(meter_reading, sqft_windspeed) AS correlation
FROM `ashrae_dataset.silver_norm_features_v2`
UNION ALL
SELECT 'temp_dewtemp' AS feature, CORR(meter_reading, temp_dewtemp) AS correlation
FROM `ashrae_dataset.silver_norm_features_v2`
UNION ALL
SELECT 'year_built_sq' AS feature, CORR(meter_reading, year_built_sq) AS correlation
FROM `ashrae_dataset.silver_norm_features_v2`;



-- basic stats from meter_reading (variable to predict)

SELECT
  COUNT(*) AS total_rows,
  MIN(meter_reading) AS min_reading,
  MAX(meter_reading) AS max_reading,
  AVG(meter_reading) AS avg_reading,
  STDDEV(meter_reading) AS stddev_reading,
  
  -- Percentils to get scatter
  APPROX_QUANTILES(meter_reading, 10) AS deciles
FROM
  `ashrae_dataset.silver_norm_features_v2`;


SELECT
  ROUND(meter_reading, 0) AS reading_bin,
  COUNT(*) AS frequency
FROM
  `ashrae_dataset.silver_norm_features_v2`
GROUP BY reading_bin
ORDER BY reading_bin
LIMIT 1000; -- limit if there is too many distinct values

-- results: too many 0 values (10% aprox) and some rows with very high values (outliers)
-- to avoid influence of both them, we apply logaritmic scale to meter_reading, so we reduce their influence

CREATE OR REPLACE TABLE `ashrae_dataset.silver_norm_features_v3` AS
SELECT
    *,
    LOG(meter_reading + 1) AS meter_reading_log
FROM
    `ashrae_dataset.silver_norm_features_v2`;



-- normalize columns year_built & floor_count, and one-hot encoding applied to primary_use

CREATE OR REPLACE TABLE `ashrae_dataset.silver_norm_features_v4` AS
SELECT
  -- normalized columns from v3
  square_feet_norm,
  air_temperature_norm,
  cloud_coverage_norm,
  dew_temperature_norm,
  precip_depth_1_hr_norm,
  sea_level_pressure_norm,
  wind_direction_norm,
  wind_speed_norm,

  -- new normalized columns
  (year_built - (SELECT MIN(year_built) FROM `ashrae_dataset.silver_norm_features_v3`))
  / NULLIF((SELECT MAX(year_built) FROM `ashrae_dataset.silver_norm_features_v3`) -
           (SELECT MIN(year_built) FROM `ashrae_dataset.silver_norm_features_v3`), 0)
  AS year_built_norm,

  (floor_count - (SELECT MIN(floor_count) FROM `ashrae_dataset.silver_norm_features_v3`))
  / NULLIF((SELECT MAX(floor_count) FROM `ashrae_dataset.silver_norm_features_v3`) -
           (SELECT MIN(floor_count) FROM `ashrae_dataset.silver_norm_features_v3`), 0)
  AS floor_count_norm,

  -- temporal variables
  hour,
  month,
  is_weekend,
  month_sin,
  month_cos,
  hour_sin,
  hour_cos,

  -- existing combinations
  sqft_airtemp,
  sqft_windspeed,
  temp_dewtemp,
  year_built_sq,

  -- categorical variables to post-separation
  meter,
  primary_use,

  -- One-hot encoding to primary_use
  CASE WHEN primary_use IN ('Education', 'Office', 'Entertainment/public assembly', 'Lodging/residential', 'Public services', 'Healthcare')
       THEN primary_use ELSE 'Other' END AS primary_use_grouped,

  CASE WHEN primary_use = 'Education' THEN 1 ELSE 0 END AS pu_education,
  CASE WHEN primary_use = 'Office' THEN 1 ELSE 0 END AS pu_office,
  CASE WHEN primary_use = 'Entertainment/public assembly' THEN 1 ELSE 0 END AS pu_entertainment,
  CASE WHEN primary_use = 'Lodging/residential' THEN 1 ELSE 0 END AS pu_lodging,
  CASE WHEN primary_use = 'Public services' THEN 1 ELSE 0 END AS pu_public_services,
  CASE WHEN primary_use = 'Healthcare' THEN 1 ELSE 0 END AS pu_healthcare,
  CASE WHEN primary_use NOT IN ('Education', 'Office', 'Entertainment/public assembly', 'Lodging/residential', 'Public services', 'Healthcare')
       THEN 1 ELSE 0 END AS pu_other,

  -- pbjetive variable to predict
  meter_reading_log,

  -- indicator split train/test
  data_split

FROM `ashrae_dataset.silver_norm_features_v3`;



-- adding new timetable column from hour data

CREATE OR REPLACE TABLE `ashrae_dataset.silver_norm_features_v5` AS
SELECT
  *,
  CASE
    WHEN hour BETWEEN 0 AND 8 THEN 'morning'
    WHEN hour BETWEEN 9 AND 16 THEN 'afternoon'
    ELSE 'evening'
  END AS hour_block
FROM `ashrae_dataset.silver_norm_features_v4`;