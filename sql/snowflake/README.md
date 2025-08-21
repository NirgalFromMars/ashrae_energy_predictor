# Snowflake SQL

This folder contains all the SQL scripts and configurations that were executed in **Snowflake** during the first phase of the ASHRAE Energy Predictor project.

## Structure

- `dbt_bronze_silver_gold/`:  
  Contains the **dbt project** (`ashrae_project`) when it was initially connected to Snowflake.  
  - Includes the `dbt_project.yml` file, the `models/` folder, and supporting configurations.  
  - This project generated the **bronze, silver, and gold tables** directly in Snowflake.  
  - These models were later adapted to BigQuery to continue with ML experiments.

- `exercises/`:  
  Contains **advanced SQL practice queries** executed in Snowflake (Block 1).  
  - Scripts are saved as `.sql` files with English titles and comments.  
  - These exercises were designed to practice and strengthen SQL knowledge directly in Snowflake using the project dataset.

## Notes
- The dbt project was first developed in Snowflake and later migrated to BigQuery.  
- No preprocessing or ML queries were executed in Snowflake. The main ML work was carried out in BigQuery.  
- This folder documents the **initial modeling work (dbt)** and the **SQL practice exercises**.
