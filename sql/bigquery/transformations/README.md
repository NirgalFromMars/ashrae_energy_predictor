# BigQuery Transformations

This folder contains the SQL scripts used for additional data transformations in BigQuery.

## Context
The bronze, silver, and gold layers were created automatically through the **dbt project** (`ashrae_project`), which was initially developed for Snowflake and then adapted to BigQuery. Therefore, there are no manual SQL scripts for those layers in this folder (they're at Snowflake subfolder).

## Preprocessing Workflow
The only manual SQL script included here is:
- `preprocessing_features.sql`: performs feature engineering, normalization, and data preparation steps, generating the final table `silver_norm_features_v5`.

During the preprocessing pipeline, two intermediate tables were generated:
- `silver_train_normalized`: contained normalized training data.
- `silver_split`: contained the train/test split after normalization.

⚠️ Note: The exact SQL used to generate these two intermediate tables was executed directly in BigQuery Console and not preserved. Their purpose is documented here for completeness.

## Output
The final table from this preprocessing flow is `silver_norm_features_v5`, which is used as input for ML models (both in BigQuery ML and in Jupyter/Python).
