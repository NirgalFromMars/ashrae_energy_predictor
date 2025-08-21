-- dnn_regressor after pre-processed/normalized numeric columns at silver_train table

-- normalized columns creating a new training data table

CREATE OR REPLACE TABLE ashrae_dataset.silver_train_normalized AS
WITH stats AS (
  SELECT
    MIN(meter_reading) AS min_meter_reading,
    MAX(meter_reading) AS max_meter_reading,
    MIN(square_feet) AS min_square_feet,
    MAX(square_feet) AS max_square_feet,
    MIN(air_temperature) AS min_air_temperature,
    MAX(air_temperature) AS max_air_temperature,
    MIN(cloud_coverage) AS min_cloud_coverage,
    MAX(cloud_coverage) AS max_cloud_coverage,
    MIN(dew_temperature) AS min_dew_temperature,
    MAX(dew_temperature) AS max_dew_temperature,
    MIN(precip_depth_1_hr) AS min_precip_depth_1_hr,
    MAX(precip_depth_1_hr) AS max_precip_depth_1_hr,
    MIN(sea_level_pressure) AS min_sea_level_pressure,
    MAX(sea_level_pressure) AS max_sea_level_pressure,
    MIN(wind_direction) AS min_wind_direction,
    MAX(wind_direction) AS max_wind_direction,
    MIN(wind_speed) AS min_wind_speed,
    MAX(wind_speed) AS max_wind_speed
  FROM ashrae_dataset.silver_train
)

SELECT
  s.*,
  -- Normalized columns
  (s.square_feet - st.min_square_feet) / (st.max_square_feet - st.min_square_feet) AS square_feet_norm,
  (s.air_temperature - st.min_air_temperature) / (st.max_air_temperature - st.min_air_temperature) AS air_temperature_norm,
  (s.cloud_coverage - st.min_cloud_coverage) / (st.max_cloud_coverage - st.min_cloud_coverage) AS cloud_coverage_norm,
  (s.dew_temperature - st.min_dew_temperature) / (st.max_dew_temperature - st.min_dew_temperature) AS dew_temperature_norm,
  (s.precip_depth_1_hr - st.min_precip_depth_1_hr) / (st.max_precip_depth_1_hr - st.min_precip_depth_1_hr) AS precip_depth_1_hr_norm,
  (s.sea_level_pressure - st.min_sea_level_pressure) / (st.max_sea_level_pressure - st.min_sea_level_pressure) AS sea_level_pressure_norm,
  (s.wind_direction - st.min_wind_direction) / (st.max_wind_direction - st.min_wind_direction) AS wind_direction_norm,
  (s.wind_speed - st.min_wind_speed) / (st.max_wind_speed - st.min_wind_speed) AS wind_speed_norm
FROM
  ashrae_dataset.silver_train s CROSS JOIN stats st


-- create new table with split train/test

CREATE OR REPLACE TABLE `ashrae_dataset.silver_norm_split` AS 
SELECT
  *,
  -- TRUE si es TRAIN (80%), FALSE si es TEST (20%)
  MOD(ABS(FARM_FINGERPRINT(CAST(building_id AS STRING))), 10) < 8 AS data_split
FROM `ashrae_dataset.silver_train_normalized`;



-- CREATE MODEL & TRAINING

CREATE OR REPLACE MODEL `ashrae_dataset.dnn_regressor_v3`
OPTIONS(
  model_type = 'dnn_regressor',
  input_label_cols = ['meter_reading'],
  hidden_units = [128, 64, 32],      -- 3 elements = 3 hidden layers, and neurons by layer (decreasing in size to capture complexity and then condense)
  learn_rate = 0.01,                 -- learning_rate lower than default (to avoid big steps at optimization)
  max_iterations = 50,              -- increasing epochs (default used to be 10)
  data_split_method = 'NO_SPLIT'
) AS
SELECT
    meter,
    hour,
    month,
    is_weekend,
    primary_use,
    square_feet_norm,
    year_built,
    floor_count,
    air_temperature_norm,
    dew_temperature_norm,
    cloud_coverage_norm,
    precip_depth_1_hr_norm,
    sea_level_pressure_norm,
    wind_direction_norm,
    wind_speed_norm,
    meter_reading
FROM
  `ashrae_dataset.silver_norm_split`
WHERE
  data_split = TRUE;


-- EVALUATE

SELECT *
FROM ML.EVALUATE(
  MODEL `ashrae_dataset.dnn_regressor_v3`,
  (
    SELECT
      meter,
      hour,
      month,
      is_weekend,
      primary_use,
      square_feet_norm,
      year_built,
      floor_count,
      air_temperature_norm,
      dew_temperature_norm,
      cloud_coverage_norm,
      precip_depth_1_hr_norm,
      sea_level_pressure_norm,
      wind_direction_norm,
      wind_speed_norm,
      meter_reading
    FROM `ashrae_dataset.silver_norm_split`
    WHERE data_split = FALSE
  )
);


-- save metrics at "evaluation_results" table

INSERT INTO `ashrae_dataset.evaluation_results`
SELECT
  'dnn_regressor_v3' AS model_name,
  *
FROM
  ML.EVALUATE(MODEL `ashrae_dataset.dnn_regressor_v3`,
    (SELECT
       meter,
       hour,
       month,
       is_weekend,
       primary_use,
       square_feet_norm,
       year_built,
       floor_count,
       air_temperature_norm,
       dew_temperature_norm,
       cloud_coverage_norm,
       precip_depth_1_hr_norm,
       sea_level_pressure_norm,
       wind_direction_norm,
       wind_speed_norm,
       meter_reading
     FROM `ashrae_dataset.silver_norm_split` 
     WHERE data_split = FALSE)
  );