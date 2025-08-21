# BigQuery SQL

This folder contains all the SQL scripts and queries that were executed in **Google BigQuery** as part of the ASHRAE Energy Predictor project.

## Structure
- `transformations/`:  
  Contains preprocessing SQL scripts applied on top of the dbt-generated tables.  
  - Main script: `preprocessing_features.sql`  
  - Output: `silver_norm_features_v5` (final input for ML models)  
  - Includes documentation of intermediate tables (`silver_train_normalized`, `silver_split`).

- `ml_models/`:  
  Contains SQL queries used to train, evaluate, and generate predictions with **BigQuery ML**.  
  - 14 base queries are included.  
  - From these queries, a total of 39 models were trained (Linear Regression, Boosted Tree, DNN).  
  - Results stored in BigQuery table `evaluation_results`.  
  - The models themselves are not included in this repository (BigQuery ML stores them internally).

## Notes
- The **bronze, silver, and gold layers** were not created manually with SQL, but automatically through the **dbt project** (`ashrae_project`), which was adapted to BigQuery.  
- SQL scripts in this folder focus only on **additional transformations** and **ML experiments**.  
- Access to BigQuery datasets is not provided here (credentials are private). Anyone wishing to reproduce this project must use their own BigQuery account.
