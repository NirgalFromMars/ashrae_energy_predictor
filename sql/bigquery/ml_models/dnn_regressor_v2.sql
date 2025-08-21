-- dnn_regressor with a deeper arquitecture and hiperparameters adjustments

-- CREATE MODEL & TRAINING

CREATE OR REPLACE MODEL `ashrae_dataset.dnn_regressor_v2`
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
FROM
  `ashrae_dataset.silver_split`
WHERE
  data_split = TRUE;


-- EVALUATE

SELECT *
FROM ML.EVALUATE(
  MODEL `ashrae_dataset.dnn_regressor_v2`,
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


-- save metrics at "evaluation_results" table

INSERT INTO `ashrae_dataset.evaluation_results`
SELECT
  'dnn_regressor_v2' AS model_name,
  *
FROM
  ML.EVALUATE(MODEL `ashrae_dataset.dnn_regressor_v2`,
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