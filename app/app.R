# app.R
library(shiny)
library(DT)
library(ggplot2)
library(forecast)
library(rpart)
library(rpart.plot)
library(gridExtra)

# Permitir archivos grandes
options(shiny.maxRequestSize = 100*1024^2)  # 1000 MB

# Cargar los módulos
source("modules/data_upload_module.R")          # Módulo de carga de datos
source("modules/regression_module.R")           # Módulo de regresión lineal
source("modules/polynomial_regression_module.R")# Módulo de regresión polinómica
source("modules/graphics_module.R")             # Módulo de gráficos adicionales
source("modules/clustering_module.R")           # Módulo de clustering
source("modules/decision_tree_module.R")        # Módulo de árboles de decisión
source("modules/arima_module.R")                # Módulo ARIMA
source("modules/time_series_module.R")          # Módulo de análisis de series temporales
source("modules/export_module.R")               # Módulo de exportación

# Definir la UI principal
ui <- fluidPage(
    titlePanel(
        div(
            h1("Shiny Machine Learning Dashboard", style = "text-align: center;"),
            span("Daniel Bonifaz-Calvo", style = "font-size: small; color: gray; text-align: center; display: block;")
        )
    ),
    sidebarLayout(
        sidebarPanel(
            h3("Options"),
            data_upload_ui("data_upload"),          # Módulo de carga con opción para mostrar u ocultar la tabla
            hr(),                                   # Línea divisoria
            h4("Regression Analysis"),
            regression_inputs("regression"),        # Módulo de regresión lineal
            hr(),
            h4("Polynomial Regression"),
            polynomial_regression_inputs("poly_regression"), # Módulo de regresión polinómica
            hr(),
            h4("Additional Graphics"),
            graphics_inputs("graphics"),            # Módulo de gráficos adicionales
            hr(),
            h4("Clustering Analysis"),
            clustering_inputs("clustering"),        # Módulo de clustering
            hr(),
            h4("Decision Tree Analysis"),
            decision_tree_inputs("decision_tree"),  # Módulo de árboles de decisión
            hr(),
            h4("Time Series Analysis"),
            time_series_inputs("time_series")       # Módulo de análisis de series temporales
        ),
        mainPanel(
            h3("Results"),
            tabsetPanel(
                tabPanel("Regression Output", regression_outputs("regression")),
                tabPanel("Polynomial Regression", polynomial_regression_outputs("poly_regression")),
                tabPanel("Additional Graphics", graphics_outputs("graphics")),
                tabPanel("Clustering", clustering_outputs("clustering")),
                tabPanel("Decision Tree", decision_tree_outputs("decision_tree")),
                tabPanel("Time Series Analysis", time_series_outputs("time_series"))
            )
        )
    )
)

# Definir el servidor principal
server <- function(input, output, session) {
    # Cargar los datos
    data <- data_upload_server("data_upload")
    
    # Llamar a los módulos con los datos cargados
    regression_server("regression", data)              # Módulo de regresión lineal
    polynomial_regression_server("poly_regression", data) # Módulo de regresión polinómica
    graphics_server("graphics", data)                  # Módulo de gráficos adicionales
    clustering_server("clustering", data)              # Módulo de clustering
    decision_tree_server("decision_tree", data)        # Módulo de árboles de decisión
    time_series_server("time_series", data)            # Módulo de análisis de series temporales
}

# Ejecutar la aplicación
shinyApp(ui = ui, server = server)
