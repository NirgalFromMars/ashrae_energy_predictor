--  CREATE MODEL & TRAINING

CREATE OR REPLACE MODEL `ashrae_dataset.linear_reg_meter`
OPTIONS(
  model_type = 'linear_reg',
  input_label_cols = ['meter_reading']
) AS
SELECT
  *
FROM
  `ashrae_dataset.silver_train`;


-- EVALUATE

SELECT
  *
FROM
  ML.EVALUATE(MODEL `ashrae_dataset.linear_reg_meter`,
    (
      SELECT
        *
      FROM
        `ashrae_dataset.silver_train`
    ));


-- PREDICTIONS

SELECT
  meter_reading AS actual,
  predicted_meter_reading AS predicted
FROM
  ML.PREDICT(MODEL `ashrae_dataset.linear_reg_meter`,
    (
      SELECT
        *
      FROM
        `ashrae_dataset.silver_train`
      LIMIT 100
    ));