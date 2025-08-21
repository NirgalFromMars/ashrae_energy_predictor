# ASHRAE dbt Project

This repository contains the `dbt` project used to model and transform the ASHRAE energy prediction dataset. The pipeline was designed following a multi-layer architecture (bronze → silver → gold), using Snowflake as the data warehouse.

## 🏗️ Project Architecture

The project is organized into three modeling layers:

### 🔹 Bronze Layer
Raw ingested data from the ASHRAE dataset:
- `bronze_train`
- `bronze_test`
- `bronze_building_metadata`
- `bronze_weather_train`
- `bronze_weather_test`

### 🔸 Silver Layer
Cleansed and enriched datasets with meaningful joins and derived fields:
- `silver_train`: joined with building metadata and weather data, with new timestamp-based features (hour, day, month, weekday, weekend).
- `silver_test`: same logic applied to the test data.

### 🟡 Gold Layer
Aggregated and ML-ready datasets:
- `gold_train_summary_by_building`: aggregated metrics per building.
- `gold_train_hourly_avg`: average meter readings by hour.
- `gold_train_cleaned_for_ml`: cleaned dataset with no missing values, ready for ML training.

## ✅ Data Quality Testing

The project includes a set of **33 tests**, covering:
- `not_null` and `unique` constraints
- `accepted_values` checks on categorical fields (e.g., `meter`, `primary_use`)

Tests were defined directly in the `schema.yml` files and executed using:

dbt test

📘 Documentation
Documentation was generated using:   dbt docs generate

It can be explored locally with:   dbt docs serve

This provides an interactive interface to inspect models, relationships, column-level descriptions, and associated tests.

👉 A sample screenshot of the lineage graph or model overview can be found in the project documentation folder or included in the GitHub README once the full project is published.

📦 Environment
dbt version: 1.x
Adapter: dbt-snowflake
Warehouse: Snowflake
Data source: ASHRAE Energy Prediction Dataset (Kaggle)
