-- new model is applied: boosted_tree_regressor instead of linear regressor
-- better filtered columns are applied to model (all with influence into meter_reading)

--  CREATE MODEL & TRAINING

CREATE OR REPLACE MODEL `ashrae_dataset.boosted_reg_meter`
OPTIONS(
  model_type = 'boosted_tree_regressor',
  input_label_cols = ['meter_reading'],
  max_iterations = 50  -- Puedes ajustar este valor
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
FROM `ashrae_dataset.silver_train`;



-- EVALUATE

SELECT * 
FROM ML.EVALUATE(MODEL `ashrae_dataset.boosted_reg_meter`,
  (SELECT * FROM `ashrae_dataset.silver_train`)
);


-- PREDICTIONS

SELECT
  meter_reading AS actual,
  predicted_meter_reading AS predicted
FROM
  ML.PREDICT(MODEL `ashrae_dataset.boosted_reg_meter`,
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
      FROM `ashrae_dataset.silver_train`
      LIMIT 100
    ));