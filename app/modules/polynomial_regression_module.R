# polynomial_regression_module.R
library(ggplot2)
library(Metrics)

# UI del módulo para controles
polynomial_regression_inputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Polynomial Regression Controls"),
        selectInput(ns("x_var"), "Select X Variable", choices = NULL),
        selectInput(ns("y_var"), "Select Y Variable", choices = NULL),
        numericInput(ns("degree"), "Polynomial Degree", value = 2, min = 1, max = 5),
        actionButton(ns("run_poly"), "Run Polynomial Regression")
    )
}

# UI del módulo para salidas
polynomial_regression_outputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Polynomial Regression Plot"),
        plotOutput(ns("poly_plot"), height = "400px"),
        hr(),
        h4("Performance Metrics"),
        verbatimTextOutput(ns("metrics_output")),
        hr(),
        export_ui(ns("export"))  # Añadir módulo de exportación
    )
}

# Server del módulo
polynomial_regression_server <- function(id, data) {
    moduleServer(id, function(input, output, session) {
        model <- reactiveVal(NULL)

        # Actualizar opciones de variables
        observe({
            req(data())
            numeric_vars <- names(data())[sapply(data(), is.numeric)]
            updateSelectInput(session, "x_var", choices = numeric_vars, selected = numeric_vars[1])
            updateSelectInput(session, "y_var", choices = numeric_vars, selected = numeric_vars[2])
        })

        # Entrenar el modelo
        observeEvent(input$run_poly, {
            req(input$x_var, input$y_var, data())
            df <- data()[, c(input$x_var, input$y_var)]
            colnames(df) <- c("X", "Y")
            poly_formula <- as.formula(paste("Y ~ poly(X, ", input$degree, ", raw = TRUE)", sep = ""))
            fit <- lm(poly_formula, data = df)
            model(fit)
        })

        # Gráfico de regresión polinómica
        poly_plot <- reactive({
            req(model(), data())
            df <- data()[, c(input$x_var, input$y_var)]
            colnames(df) <- c("X", "Y")
            df$Fitted <- predict(model(), df)
            ggplot(df, aes(x = X, y = Y)) +
                geom_point(color = "blue", size = 2) +
                geom_line(aes(y = Fitted), color = "red", size = 1) +
                labs(title = "Polynomial Regression", x = input$x_var, y = input$y_var) +
                theme_minimal()
        })

        output$poly_plot <- renderPlot({ poly_plot() })

        # Mostrar métricas de rendimiento
        output$metrics_output <- renderPrint({
            req(model(), data())
            df <- data()[, c(input$x_var, input$y_var)]
            colnames(df) <- c("X", "Y")
            predictions <- predict(model(), df)
            actuals <- df$Y

            r2 <- 1 - sum((actuals - predictions)^2) / sum((actuals - mean(actuals))^2)
            mse_val <- mse(actuals, predictions)
            mae_val <- mae(actuals, predictions)

            cat("R² (Coefficient of Determination):", round(r2, 4), "\n")
            cat("MSE (Mean Squared Error):", round(mse_val, 4), "\n")
            cat("MAE (Mean Absolute Error):", round(mae_val, 4), "\n")
        })

        # Exportar resultados
        export_server("export", data, poly_plot)
    })
}
