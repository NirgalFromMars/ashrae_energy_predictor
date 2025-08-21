-- applying dnn regressor after all transformations over input data (normalization, selection, interactions, filtering...), as it's been done with boosted_tree_reg in the last version (boosted_tree_reg_log_by_meter_v4)


-- CREATE/TRAIN MODEL
CREATE OR REPLACE MODEL `ashrae_dataset.dnn_regressor_log_v1_meter0`
OPTIONS (
  model_type = 'DNN_REGRESSOR',
  input_label_cols = ['meter_reading_log'],
  data_split_method = 'CUSTOM',
  data_split_col = 'data_split',
  hidden_units = [128, 64]
) AS
SELECT
  square_feet_norm,
  year_built_norm,
  floor_count_norm,
  month_sin,
  hour_cos,
  meter_reading_log,
  data_split
FROM `ashrae_dataset.silver_norm_features_v5`
WHERE meter = 0;


-- EVALUATE
SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `ashrae_dataset.dnn_regressor_log_v1_meter0_simplified1`,
    (
      SELECT
        square_feet_norm,
        year_built_norm,
        floor_count_norm,
        month_sin,
        hour_cos,
        meter_reading_log
      FROM
        `ashrae_dataset.silver_norm_features_v5`
      WHERE
        meter = 0
        AND data_split = TRUE
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
    'dnn_regressor_log_v1_meter0_simplified1' AS model_name,
    e.*
  FROM
    ML.EVALUATE(MODEL `ashrae_dataset.dnn_regressor_log_v1_meter0_simplified1`,
      (SELECT
        square_feet_norm,
        year_built_norm,
        floor_count_norm,
        month_sin,
        hour_cos,
        meter_reading_log
       FROM
         `ashrae_dataset.silver_norm_features_v5`, param
       WHERE
         data_split = FALSE
         AND meter = param.m
      )
    ) AS e
);