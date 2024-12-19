# Performance Metrics Module (`performance_metrics_module.R`)

## Overview
The `performance_metrics_module.R` computes and displays key performance metrics for various machine learning models within the Shiny Machine Learning Dashboard. This module helps users evaluate the accuracy and efficiency of their models.

## Key Features
- **Regression Metrics**: Evaluate linear and polynomial regression models with:
  - **R² (Coefficient of Determination)**: Measures the proportion of variance explained by the model.
  - **MSE (Mean Squared Error)**: Represents the average squared difference between observed and predicted values.
  - **MAE (Mean Absolute Error)**: Indicates the average absolute difference between observed and predicted values.
- **Real-Time Display**: Metrics are updated dynamically based on model input and selection.

## What You Can Achieve
Using the `performance_metrics_module.R`, you can:
1. Assess the quality of regression models using industry-standard metrics.
2. Compare different models and refine them for better performance.
3. Integrate performance results into reports using export functionalities.

## Visualizations and Results
- **Metrics Display**: Shows R², MSE, and MAE in a structured text output.

---

**Note**: Ensure the dataset includes appropriate numeric columns for regression analysis before computing metrics.

By: Daniel Bonifaz-Calvo
