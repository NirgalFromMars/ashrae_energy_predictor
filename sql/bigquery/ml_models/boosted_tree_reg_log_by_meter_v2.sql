-- idem as previous version (applying last boosted_tree_regressor with logaritmic objective variable, but for every meter value independently (different types: electricity, water, etc...)), plus:
--    * additional pre-processed actions: normalizing year_built & floor_count, applying one-hot encoding to primary_use column
--    * divide data by meter and also by primary_use

-- CREATE/TRAIN MODEL

CREATE OR REPLACE MODEL `ashrae_dataset.boosted_tree_reg_log_v4_meter0_ent`
OPTIONS(
  model_type='BOOSTED_TREE_REGRESSOR',
  input_label_cols=['meter_reading_log']
) AS

WITH param AS (
  SELECT 0 AS m -- <== change meter value to filter
)

SELECT
    square_feet_norm,
    year_built_norm,
    floor_count_norm,
    air_temperature_norm,
    cloud_coverage_norm,
    dew_temperature_norm,
    precip_depth_1_hr_norm,
    sea_level_pressure_norm,
    wind_direction_norm,
    wind_speed_norm,
    is_weekend,
    month_sin,
    month_cos,
    hour_sin,
    hour_cos,
    sqft_airtemp,
    sqft_windspeed,
    temp_dewtemp,
    year_built_sq,
    pu_education,
    pu_office,
    pu_entertainment,
    pu_lodging,
    pu_public_services,
    pu_healthcare,
    pu_other,
    meter_reading_log
FROM
    `ashrae_dataset.silver_norm_features_v4`,
    param
WHERE
    data_split = TRUE
    AND meter = param.m
    AND pu_entertainment = 1;


-- EVALUATE

WITH param AS (
  SELECT 0 AS m
)

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `ashrae_dataset.boosted_tree_reg_log_v4_meter0_ent`,
    (
      SELECT
        square_feet_norm,
        year_built_norm,
        floor_count_norm,
        air_temperature_norm,
        cloud_coverage_norm,
        dew_temperature_norm,
        precip_depth_1_hr_norm,
        sea_level_pressure_norm,
        wind_direction_norm,
        wind_speed_norm,
        is_weekend,
        month_sin,
        month_cos,
        hour_sin,
        hour_cos,
        sqft_airtemp,
        sqft_windspeed,
        temp_dewtemp,
        year_built_sq,
        pu_education,
        pu_office,
        pu_entertainment,
        pu_lodging,
        pu_public_services,
        pu_healthcare,
        pu_other,
        meter_reading_log
      FROM
        `ashrae_dataset.silver_norm_features_v4`,
        param
      WHERE
        data_split = FALSE
        AND meter = param.m
        AND pu_entertainment = 1
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