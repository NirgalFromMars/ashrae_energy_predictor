-- after applying dnn_regressor with different configurations and get bad metrics as results... we come back to boosted_tree_regressor that gave
-- us better results, and we're going to apply it after Pre-Processesing code creating a new objetive variable to predict as logaritm of original
-- meter_reading

-- CREATE/TRAIN MODEL

CREATE OR REPLACE MODEL `ashrae_dataset.boosted_tree_reg_log`
OPTIONS(
  model_type = 'BOOSTED_TREE_REGRESSOR',
  input_label_cols = ['meter_reading_log']
) AS
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
    -- cyclic variables
    month_sin,
    month_cos,
    hour_sin,
    hour_cos,
    -- interactions
    sqft_airtemp,
    sqft_windspeed,
    temp_dewtemp,
    year_built_sq,
    -- objective variable must be included
    meter_reading_log
FROM
    `ashrae_dataset.silver_norm_features_v3`
WHERE
    data_split = TRUE;


-- EVALUATE MODEL

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `ashrae_dataset.boosted_tree_reg_log`,
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
        `ashrae_dataset.silver_norm_features_v3`
      WHERE
        data_split = FALSE
    )
  );

