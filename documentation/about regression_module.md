# Regression Module (`regression_module.R`)

## Overview
The `regression_module.R` provides tools to perform linear regression analysis within the Shiny Machine Learning Dashboard. It allows users to dynamically select variables, visualize results, and compute performance metrics for their models.

## Key Features
- **Dynamic Variable Selection**: Choose X and Y variables for regression from the uploaded dataset.
- **Regression Visualization**: Generates a scatter plot with a fitted regression line.
- **Performance Metrics**: Computes and displays key metrics:
  - R² (Coefficient of Determination)
  - MSE (Mean Squared Error)
  - MAE (Mean Absolute Error)
- **Integration**: Results and metrics can be exported for further use.

## What You Can Achieve
Using the `regression_module.R`, you can:
1. Analyze relationships between variables in your dataset using linear regression.
2. Visualize the regression line and the data points on a scatter plot.
3. Understand the quality of the model through performance metrics.

## Visualizations and Results
- **Scatter Plot with Regression Line**: Visualizes the relationship between X and Y variables.
- **Performance Metrics**: Displayed in a structured format below the plot.
- **Export Options**: Save results as CSV or export plots as PDF.

---

**Note**: Ensure the dataset contains numeric columns for selecting X and Y variables. Non-numeric columns will not be listed.

By: Daniel Bonifaz-Calvo
