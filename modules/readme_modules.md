# Modules Folder

This folder contains modularized scripts for the Shiny application.
- Each module handles a specific functionality (e.g., regression, clustering, etc.).
- Modules help in organizing the code and improving reusability.

**Modules included:**

1. `data_upload_module.R`: Handles data upload and preview.

2. `regression_module.R`: Implements linear regression.

3. `clustering_module.R`: Performs clustering using K-Means.

4. `time_series_module.R`: Conducts time series analysis.

**How to use:**

1. Source these modules in the `app.R` file.

2. Use the corresponding `*_ui` and `*_server` functions to integrate modules into the app.
