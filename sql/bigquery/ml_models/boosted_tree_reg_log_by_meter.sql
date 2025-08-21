-- applying last boosted_tree_regressor with logaritmic objective variable, but for every meter value independently (different types: electricity, water, etc...)

-- CREATE/TRAIN MODEL

CREATE OR REPLACE MODEL `ashrae_dataset.boosted_tree_reg_log_meter3`
OPTIONS(
  model_type='BOOSTED_TREE_REGRESSOR',
  input_label_cols=['meter_reading_log']
) AS

WITH param AS (
  SELECT 3 AS m -- <== change meter value to filter
)

SELECT
    square_feet_norm,
    year_built,
    floor_count,
    meter,
    primary_use,
    air_temperature_norm,
    cloud_coverage_norm,
    dew_temperature_norm,
    precip_depth_1_hr_norm,
    sea_level_pressure_norm,
    wind_direction_norm,
    wind_speed_norm,
    hour,
    month,
    is_weekend,
    month_sin,
    month_cos,
    hour_sin,
    hour_cos,
    sqft_airtemp,
    sqft_windspeed,
    temp_dewtemp,
    year_built_sq,
    meter_reading_log
FROM
    `ashrae_dataset.silver_norm_features_v3`,
    param
WHERE
    data_split = TRUE
    AND meter = param.m;


-- EVALUATE

WITH param AS (
  SELECT 3 AS m
)

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `ashrae_dataset.boosted_tree_reg_log_meter3`,
    (
      SELECT
        square_feet_norm,
        year_built,
        floor_count,
        meter,
        primary_use,
        air_temperature_norm,
        cloud_coverage_norm,
        dew_temperature_norm,
        precip_depth_1_hr_norm,
        sea_level_pressure_norm,
        wind_direction_norm,
        wind_speed_norm,
        hour,
        month,
        is_weekend,
        month_sin,
        month_cos,
        hour_sin,
        hour_cos,
        sqft_airtemp,
        sqft_windspeed,
        temp_dewtemp,
        year_built_sq,
        meter_reading_log
      FROM
        `ashrae_dataset.silver_norm_features_v3`,
        param
      WHERE
        data_split = FALSE
        AND meter = param.m
    )
  );


-- save metrics results at evaluation_results table

INSERT INTO `ashrae_dataset.evaluation_results`
SELECT *
FROM (
  WITH param AS (
    SELECT 3 AS m
  )
  SELECT
    'boosted_tree_reg_log_meter3' AS model_name,
    e.*
  FROM
    ML.EVALUATE(MODEL `ashrae_dataset.boosted_tree_reg_log_meter3`,
      (SELECT
         square_feet_norm,
         year_built,
         floor_count,
         meter,
         primary_use,
         air_temperature_norm,
         cloud_coverage_norm,
         dew_temperature_norm,
         precip_depth_1_hr_norm,
         sea_level_pressure_norm,
         wind_direction_norm,
         wind_speed_norm,
         hour,
         month,
         is_weekend,
         month_sin,
         month_cos,
         hour_sin,
         hour_cos,
         sqft_airtemp,
         sqft_windspeed,
         temp_dewtemp,
         year_built_sq,
         meter_reading_log
       FROM
         `ashrae_dataset.silver_norm_features_v3`, param
       WHERE
         data_split = FALSE
         AND meter = param.m
      )
    ) AS e
);