-- hiperparameter tunning:

-- MAX_ITERATIONS Number of boosting trees. More trees can improve but also overfit. 100 - 500
-- MAX_TREE_DEPTH Maximum depth of each tree. Low depths prevent overfitting but limit learning. 3 - 8
-- LEARN_RATE Learning rate. How much each new tree adjusts. Low values (0.01-0.3) allow for more robust models. 0.01 - 0.3
-- MIN_SPLIT_LOSS Pruning. Minimum threshold for loss improvement before continuing to split nodes. 0 - 5
-- SUBSAMBLING Proportion of data used in each iteration. Prevents overfitting. 0.5 - 1.0
-- L1_REG L1 regularization (penalizes large weights). 0 - 1
-- L2_REG L2 regularization (similar but with a different penalty). 0 - 1

-- combinations we'll apply (manually, without GridSearch):
-- v3a -> MAX_ITERATIONS=100	MAX_TREE_DEPTH=5	LEARN_RATE=0.1	MIN_SPLIT_LOSS=0	SUBSAMPLE=0.8	L1_REG=0	L2_REG=0
-- v3b -> MAX_ITERATIONS=300	MAX_TREE_DEPTH=6	LEARN_RATE=0.05	MIN_SPLIT_LOSS=1	SUBSAMPLE=0.7	L1_REG=0.1	L2_REG=0.1
-- v3c -> MAX_ITERATIONS=500	MAX_TREE_DEPTH=8	LEARN_RATE=0.01	MIN_SPLIT_LOSS=2	SUBSAMPLE=0.6	L1_REG=0.2	L2_REG=0.3


CREATE OR REPLACE TABLE `ashrae_dataset.silver_split` AS
SELECT
  *,
  -- TRUE si es TRAIN (80%), FALSE si es TEST (20%)
  MOD(ABS(FARM_FINGERPRINT(CAST(building_id AS STRING))), 10) < 8 AS data_split
FROM `ashrae_dataset.silver_train`;


--  CREATE MODEL & TRAINING

CREATE OR REPLACE MODEL `ashrae_dataset.boosted_tree_v3c`
OPTIONS(
  model_type='BOOSTED_TREE_REGRESSOR',
  input_label_cols=['meter_reading'],
  data_split_method = 'CUSTOM',
  data_split_col='data_split',
  max_iterations=500,
  max_tree_depth=8,
  learn_rate=0.01,
  min_split_loss=2,
  subsample=0.6,
  l1_reg=0.2,
  l2_reg=0.3
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
FROM
  `ashrae_dataset.silver_split`;




-- EVALUATE

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `ashrae_dataset.boosted_tree_v3c`,
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
  'boosted_tree_v3c' AS model_name,
  *
FROM
  ML.EVALUATE(MODEL `ashrae_dataset.boosted_tree_v3c`,
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