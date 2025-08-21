-- neural network regressor over the train/test split table


-- CREATE MODEL & TRAINING

CREATE OR REPLACE MODEL `ashrae_dataset.dnn_regressor_v1`
OPTIONS(
  model_type='dnn_regressor',
  input_label_cols=['meter_reading'],
  data_split_method='no_split'
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
  meter_reading
FROM `ashrae_dataset.silver_split`
WHERE data_split = TRUE


-- EVALUATE

SELECT
  *
FROM
  ML.EVALUATE(MODEL `ashrae_dataset.dnn_regressor_v1`,
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
  )


-- save metrics at "evaluation_results" table

INSERT INTO `ashrae_dataset.evaluation_results`
SELECT
  'dnn_regressor_v1' AS model_name,
  *
FROM
  ML.EVALUATE(MODEL `ashrae_dataset.dnn_regressor_v1`,
    (SELECT
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
     WHERE data_split = FALSE)
  );