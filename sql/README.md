# 📂 SQL Scripts

This folder contains all SQL scripts used throughout the ASHRAE Energy Predictor project.  
They are organized by platform (**Snowflake** and **BigQuery**) and by purpose (transformations, ML models, exercises).

---

## 📑 Structure

sql/
├── snowflake/
│ ├── dbt_bronze_silver_gold/ # dbt models for Snowflake (bronze → silver → gold)
│ └── exercises/ # advanced SQL exercises (Snowflake-specific)
└── bigquery/
├── transformations/ # SQL transformations and feature preparation
└── ml_models/ # BigQuery ML models and evaluation


---

## ❄️ Snowflake

### dbt Models
- **Bronze layer**: Raw ingestion of the ASHRAE dataset.  
- **Silver layer**: Cleaned and normalized data, ready for training.  
- **Gold layer**: Feature-engineered tables for ML consumption.  

All dbt models were materialized in Snowflake during the trial phase.

### Exercises
Several Snowflake-specific features were explored:
- **Time Travel**: Querying historical versions of tables.  
- **Zero-Copy Cloning**: Creating clones of datasets for testing.  
- **Advanced SQL**: Joins, aggregations, and CTEs applied to the `silver_train` dataset.  

---

## ☁️ BigQuery

### Transformations
- Replication of the layered architecture (`silver_train`, `gold_features`) using BigQuery SQL.  
- Additional feature preparation for ML training.  

### ML Models (BigQuery ML)
- **Linear Regression** (`linear_reg.sql`)  
- **Boosted Tree Regressor** (`boosted_tree.sql`)  
- **Deep Neural Network Regressor** (`dnn_regressor.sql`)  
- **Evaluation Metrics**: Queries to store model performance (R², RMSE) into results tables.  

---

## 📌 Notes

- File naming follows a descriptive pattern (`purpose.sql`).  
- Each script is commented to explain the logic and purpose.  
- Snowflake scripts were executed in a **trial environment**; BigQuery scripts are reproducible in any GCP account with the dataset uploaded.  

---