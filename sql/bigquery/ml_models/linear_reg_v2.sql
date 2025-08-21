-- relevant variables are selected to be considered by the model, avoiding noise from non-influencers/important variables

--  CREATE MODEL & TRAINING

CREATE OR REPLACE MODEL `ashrae_dataset.linear_reg_meter_v2`
OPTIONS(
  model_type = 'linear_reg',
  input_label_cols = ['meter_reading']
) AS
SELECT
  air_temperature,
  dew_temperature,
  cloud_coverage,
  hour,
  day_of_week,
  meter_reading
FROM
  `ashrae_dataset.silver_train`;


-- EVALUATE

SELECT * 
FROM ML.EVALUATE(MODEL `ashrae_dataset.linear_reg_meter_v2`,
  (SELECT * FROM `ashrae_dataset.silver_train`)
);


-- PREDICTIONS

SELECT
  meter_reading AS actual,
  predicted_meter_reading AS predicted
FROM
  ML.PREDICT(MODEL `ashrae_dataset.linear_reg_meter_v2`,
    (
      SELECT
        air_temperature,
        dew_temperature,
        cloud_coverage,
        hour,
        day_of_week,
        meter_reading
      FROM `ashrae_dataset.silver_train`
      LIMIT 100
    ));
