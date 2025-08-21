-- idem as previous version (v2), plus:
--    * divide data by meter and also by new hour_block created column
--    * apply EXPLAIN_PREDICT() to value influence from every variable into prediction

-- CREATE/TRAIN MODEL

CREATE OR REPLACE MODEL `ashrae_dataset.boosted_tree_reg_log_v5_meter0_tuned6`
OPTIONS(
  model_type='BOOSTED_TREE_REGRESSOR',
  input_label_cols=['meter_reading_log'],
  max_iterations = 200,
  learn_rate = 0.05,
  subsample = 1,
  max_tree_depth = 8
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
    `ashrae_dataset.silver_norm_features_v5`,
    param
WHERE
    data_split = TRUE
    AND meter = param.m;
    --AND hour_block = 'afternoon';


-- EXPLAIN_PREDICT()

WITH input_data AS (
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
    `ashrae_dataset.silver_norm_features_v5`
  WHERE
    meter = 0
    AND data_split = FALSE
  -- LIMIT 100 -- up to 500 or 1000 to be more precise
)

SELECT
  attr.feature AS feature_name,
  COUNT(*) AS num_samples,
  AVG(ABS(attr.attribution)) AS mean_abs_contribution
FROM
  ML.EXPLAIN_PREDICT(
    MODEL `ashrae_dataset.boosted_tree_reg_log_v4_meter0`,
    TABLE input_data,
    STRUCT(25 AS top_k_features)
  ),
  UNNEST(top_feature_attributions) AS attr
GROUP BY feature_name
ORDER BY mean_abs_contribution DESC;


-- EVALUATE

WITH param AS (
  SELECT 0 AS m
)

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `ashrae_dataset.boosted_tree_reg_log_v5_meter0_tuned6`,
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
        `ashrae_dataset.silver_norm_features_v5`,
        param
      WHERE
        data_split = FALSE
        AND meter = param.m
        --AND hour_block = 'evening'
    )
  );


-- save metrics results at evaluation_results table

INSERT INTO `ashrae_dataset.evaluation_results`
SELECT *
FROM (
  WITH param AS (
    SELECT 0 AS m
  )
  SELECT
    'boosted_tree_reg_log_meter0_tuned6' AS model_name,
    e.*
  FROM
    ML.EVALUATE(MODEL `ashrae_dataset.boosted_tree_reg_log_v5_meter0_tuned6`,
      (SELECT
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
         `ashrae_dataset.silver_norm_features_v5`, param
       WHERE
         data_split = FALSE
         AND meter = param.m
         --AND hour_block = 'afternoon'
      )
    ) AS e
);