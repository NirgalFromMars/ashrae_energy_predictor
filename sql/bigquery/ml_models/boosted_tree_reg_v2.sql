-- dividing silver-train into train/test different datasets, one for training and the other for testing

-- split train (data_split to TRUE) /test (data_split to FALSE)

CREATE OR REPLACE TABLE `ashrae_dataset.silver_split` AS
SELECT
  *,
  -- TRUE si es TRAIN (80%), FALSE si es TEST (20%)
  MOD(ABS(FARM_FINGERPRINT(CAST(building_id AS STRING))), 10) < 8 AS data_split
FROM `ashrae_dataset.silver_train`;



--  CREATE MODEL & TRAINING

CREATE OR REPLACE MODEL `ashrae_dataset.boosted_tree_split_model`
OPTIONS(
  model_type = 'boosted_tree_regressor',
  input_label_cols = ['meter_reading'],
  data_split_method = 'CUSTOM',
  data_split_col= 'data_split'
) AS
SELECT
  meter,
  hour,
  month,
  is_weekend,
  primary_use,
  square_feet,
  year_built,
  floor_count,
  air_temperature,
  dew_temperature,
  cloud_coverage,
  precip_depth_1_hr,
  sea_level_pressure,
  wind_direction,
  wind_speed,
  meter_reading,
  data_split
FROM `ashrae_dataset.silver_split`;



-- EVALUATE

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `ashrae_dataset.boosted_tree_split_model`,
    (
      SELECT
        meter,
        hour,
        month,
        is_weekend,
        primary_use,
        square_feet,
        year_built,
        floor_count,
        air_temperature,
        dew_temperature,
        cloud_coverage,
        precip_depth_1_hr,
        sea_level_pressure,
        wind_direction,
        wind_speed,
        meter_reading
      FROM `ashrae_dataset.silver_split`
      WHERE data_split = FALSE
    )
  );



-- PREDICTIONS

SELECT
  meter_reading AS actual,
  predicted_meter_reading AS predicted
FROM
  ML.PREDICT(
    MODEL `ashrae_dataset.boosted_tree_split_model`,
    (
      SELECT
        meter,
        hour,
        month,
        is_weekend,
        primary_use,
        square_feet,
        year_built,
        floor_count,
        air_temperature,
        dew_temperature,
        cloud_coverage,
        precip_depth_1_hr,
        sea_level_pressure,
        wind_direction,
        wind_speed,
        meter_reading
      FROM `ashrae_dataset.silver_split`
      WHERE data_split = FALSE
      LIMIT 100
    )
  );