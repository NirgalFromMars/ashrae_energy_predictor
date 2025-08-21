-- from v3 we change/apply: filtering just 5 variables/columns that better explain predictive column, as we've checked at v3 with EXPLAIN_PRECIT(), and creating a simplified model (boosted_tree_reg) with them

-- CREATE/TRAIN MODEL

CREATE OR REPLACE MODEL `ashrae_dataset.boosted_tree_reg_log_v5_meter0_simplified1`
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
    month_sin,
    hour_cos,
    meter_reading_log
FROM
    `ashrae_dataset.silver_norm_features_v5`,
    param
WHERE
    data_split = TRUE
    AND meter = param.m;


-- EVALUATE

WITH param AS (
  SELECT 0 AS m
)

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `ashrae_dataset.boosted_tree_reg_log_v5_meter0_simplified1`,
    (
      SELECT
        square_feet_norm,
        year_built_norm,
        floor_count_norm,
        month_sin,
        hour_cos,
        meter_reading_log
      FROM
        `ashrae_dataset.silver_norm_features_v5`,
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
    SELECT 0 AS m
  )
  SELECT
    'boosted_tree_reg_log_meter0_simplified1' AS model_name,
    e.*
  FROM
    ML.EVALUATE(MODEL `ashrae_dataset.boosted_tree_reg_log_v5_meter0_simplified1`,
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