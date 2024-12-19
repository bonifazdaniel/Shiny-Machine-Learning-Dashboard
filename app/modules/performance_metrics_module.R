# performance_metrics_module.R
library(Metrics)  # Para calcular métricas como MSE y MAE

# UI del módulo para mostrar métricas de rendimiento
performance_metrics_ui <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Performance Metrics"),
        verbatimTextOutput(ns("metrics_output")),  # Mostrar las métricas
        hr(),
        export_ui(ns("export"))                   # Botones para exportar métricas
    )
}

# Server del módulo para calcular métricas de rendimiento
performance_metrics_server <- function(id, actuals, predictions) {
    moduleServer(id, function(input, output, session) {
        # Calcular las métricas de rendimiento
        metrics <- reactive({
            req(actuals(), predictions())
            r2 <- 1 - sum((actuals() - predictions())^2) / sum((actuals() - mean(actuals()))^2)
            mse_val <- mse(actuals(), predictions())
            mae_val <- mae(actuals(), predictions())
            
            # Devolver resultados como lista
            list(
                R2 = round(r2, 4),
                MSE = round(mse_val, 4),
                MAE = round(mae_val, 4)
            )
        })

        # Mostrar las métricas en la interfaz
        output$metrics_output <- renderPrint({
            req(metrics())
            cat("R² (Coefficient of Determination):", metrics()$R2, "\n")
            cat("MSE (Mean Squared Error):", metrics()$MSE, "\n")
            cat("MAE (Mean Absolute Error):", metrics()$MAE, "\n")
        })

        # Exportar métricas a CSV o PDF
        export_server(
            id = "export",
            data = reactive({
                req(metrics())
                # Crear un data.frame con las métricas
                data.frame(
                    Metric = c("R²", "MSE", "MAE"),
                    Value = c(metrics()$R2, metrics()$MSE, metrics()$MAE)
                )
            }),
            plot = NULL  # No hay gráfico asociado para métricas
        )
    })
}
