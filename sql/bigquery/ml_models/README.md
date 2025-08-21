# BigQuery ML Models

This folder contains the SQL queries used to train, evaluate, and generate predictions with different ML models directly in BigQuery ML.

## Context
- A total of **39 ML models** were created in BigQuery.
- These models belong to three families:
  - Linear Regression
  - Boosted Tree Regressor
  - Deep Neural Network (DNN)

## Queries
There are **14 base queries** in this folder. By varying hyperparameters and feature sets across these queries, the 39 models were trained.

Examples of parameters explored:
- `max_iterations`
- `learn_rate`
- `subsample`
- `max_tree_depth`

## Results
- Model evaluation results were stored in the table `evaluation_results`.
- The trained models themselves are not included in this repository, since BigQuery ML stores them internally as `MODEL` objects.

## Reproducibility
Anyone can reproduce the models by:
1. Loading the original CSV data into BigQuery.
2. Running the dbt project to generate bronze/silver/gold tables.
3. Executing the preprocessing SQL (`preprocessing_features.sql`).
4. Running the ML queries in this folder.

