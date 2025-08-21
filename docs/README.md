# Documentation & Sample Data

This folder contains supporting documentation and a small sample of the original ASHRAE dataset for testing purposes.

## Sample Dataset

- **File:** `test__sample.csv`  
- **Description:** This CSV includes the first 1,000 rows of the original `train.csv` file. It is provided as a lightweight example so that users can quickly explore the workflow without needing to download the full dataset.  
- ⚠️ Note: This is **not the full dataset**; results obtained from it will differ from those using the complete dataset.

## Original Dataset Access

The original ASHRAE Energy Predictor datasets can be downloaded from the official Kaggle competition page:

[Kaggle ASHRAE Energy Prediction](https://www.kaggle.com/competitions/ashrae-energy-prediction/data)

### Files available on Kaggle

- `building_metadata.csv` – metadata of each building
- `train.csv` – historical meter readings for training
- `test.csv` – meter readings for prediction
- `weather_train.csv` – weather data corresponding to train period
- `weather_test.csv` – weather data corresponding to test period

Users should download these files manually from Kaggle to comply with licensing restrictions.  

## Purpose

The sample dataset and this documentation aim to allow users to explore and reproduce parts of the project workflow without requiring access to the full dataset. For full analysis, download the original files from Kaggle.
