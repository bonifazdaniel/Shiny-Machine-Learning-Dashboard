# regression_module.R
library(ggplot2)
library(Metrics)

# UI del módulo de regresión
regression_inputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Regression Controls"),
        selectInput(ns("x_var"), "Select X Variable", choices = NULL),
        selectInput(ns("y_var"), "Select Y Variable", choices = NULL),
        actionButton(ns("run_regression"), "Run Regression")
    )
}

regression_outputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Regression Plot"),
        plotOutput(ns("regression_plot"), height = "400px"),
        br(),  # Espacio adicional
        hr(),  # Línea divisoria horizontal
        fluidRow(
            column(12, h4("Performance Metrics")),
            column(12, verbatimTextOutput(ns("metrics_output")))  # Métricas de rendimiento
        ),
        br(),  # Espacio adicional
        hr(),  # Línea divisoria
        fluidRow(
            column(12, h4("Export Options")),
            column(6, export_ui(ns("export")))  # Botones de exportación
        )
    )
}

# Server del módulo de regresión
regression_server <- function(id, data) {
    moduleServer(id, function(input, output, session) {
        regression_result <- reactiveVal(NULL)  # Guardar el modelo
        performance_metrics <- reactiveVal(NULL)  # Guardar métricas de rendimiento

        # Actualizar las opciones de variables
        observe({
            req(data())
            numeric_vars <- names(data())[sapply(data(), is.numeric)]
            updateSelectInput(session, "x_var", choices = numeric_vars, selected = numeric_vars[1])
            updateSelectInput(session, "y_var", choices = numeric_vars, selected = numeric_vars[2])
        })

        # Ejecutar la regresión
        observeEvent(input$run_regression, {
            req(input$x_var, input$y_var, data())
            df <- data()
            model <- lm(as.formula(paste(input$y_var, "~", input$x_var)), data = df)
            regression_result(model)

            # Calcular métricas
            predictions <- predict(model, df)
            mse <- mse(df[[input$y_var]], predictions)
            mae <- mae(df[[input$y_var]], predictions)
            r_squared <- summary(model)$r.squared

            metrics <- paste(
                "R² (Coefficient of Determination):", round(r_squared, 4), "\n",
                "MSE (Mean Squared Error):", round(mse, 4), "\n",
                "MAE (Mean Absolute Error):", round(mae, 4)
            )
            performance_metrics(metrics)
        })

        # Generar el gráfico de regresión
        output$regression_plot <- renderPlot({
            req(regression_result(), input$x_var, input$y_var, data())
            df <- data()
            ggplot(df, aes_string(x = input$x_var, y = input$y_var)) +
                geom_point(color = "blue") +
                geom_smooth(method = "lm", se = FALSE, color = "red") +
                labs(
                    title = "Linear Regression",
                    x = input$x_var,
                    y = input$y_var
                ) +
                theme_minimal()
        })

        # Mostrar las métricas de rendimiento
        output$metrics_output <- renderText({
            req(performance_metrics())
            performance_metrics()
        })

        # Exportar resultados
        export_server(
            id = "export",
            data = reactive({
                req(regression_result())
                data.frame(
                    Variable = c("R²", "MSE", "MAE"),
                    Value = c(
                        summary(regression_result())$r.squared,
                        mse(data()[[input$y_var]], predict(regression_result(), data())),
                        mae(data()[[input$y_var]], predict(regression_result(), data()))
                    )
                )
            }),
            plot = reactive({
                req(regression_result(), input$x_var, input$y_var, data())
                df <- data()
                ggplot(df, aes_string(x = input$x_var, y = input$y_var)) +
                    geom_point(color = "blue") +
                    geom_smooth(method = "lm", se = FALSE, color = "red") +
                    labs(
                        title = "Linear Regression",
                        x = input$x_var,
                        y = input$y_var
                    ) +
                    theme_minimal()
            })
        )
    })
}
