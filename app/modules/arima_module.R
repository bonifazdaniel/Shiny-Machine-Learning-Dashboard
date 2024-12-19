# arima_module.R
library(ggplot2)
library(forecast)

# UI del módulo para controles (inputs)
arima_inputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("ARIMA Model Controls"),
        selectInput(ns("time_var"), "Select Time Variable", choices = NULL),
        selectInput(ns("value_var"), "Select Value Variable", choices = NULL),
        numericInput(ns("horizon"), "Forecast Horizon (steps)", value = 10, min = 1),
        actionButton(ns("run_arima"), "Run ARIMA Model")
    )
}

# UI del módulo para salidas (outputs)
arima_outputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("ARIMA Forecast"),
        plotOutput(ns("arima_plot"), height = "400px"),
        hr(),
        h4("Residuals Plot"),
        plotOutput(ns("residual_plot"), height = "300px"),
        hr(),
        export_ui(ns("export"))  # Botones para exportar resultados
    )
}

# Server del módulo ARIMA
arima_server <- function(id, data) {
    moduleServer(id, function(input, output, session) {
        model <- reactiveVal(NULL)          # Guardar el modelo ARIMA
        forecast_data <- reactiveVal(NULL) # Guardar los datos de predicción
        
        # Actualizar las opciones de las variables
        observe({
            req(data())
            vars <- names(data())
            updateSelectInput(session, "time_var", choices = vars)
            updateSelectInput(session, "value_var", choices = vars)
        })

        # Ejecutar el modelo ARIMA
        observeEvent(input$run_arima, {
            req(input$time_var, input$value_var, data())
            df <- data()[, c(input$time_var, input$value_var)]
            colnames(df) <- c("Time", "Value")
            
            # Convertir la columna temporal a Date
            df$Time <- as.Date(df$Time, format = "%Y-%m-%d")
            df <- df[order(df$Time), ]
            
            # Crear la serie temporal
            ts_data <- ts(df$Value, frequency = 12)  # Frecuencia mensual por defecto
            
            # Ajustar el modelo ARIMA
            arima_fit <- auto.arima(ts_data)
            model(arima_fit)
            
            # Realizar la predicción
            forecast_result <- forecast(arima_fit, h = input$horizon)
            forecast_data(forecast_result)
        })

        # Graficar la predicción ARIMA
        arima_plot <- reactive({
            req(forecast_data())
            autoplot(forecast_data()) +
                labs(title = "ARIMA Forecast", x = "Time", y = "Value") +
                theme_minimal()
        })

        output$arima_plot <- renderPlot({ arima_plot() })

        # Graficar los residuos
        residual_plot <- reactive({
            req(model())
            ggAcf(residuals(model()), main = "Residuals ACF") +
                theme_minimal()
        })

        output$residual_plot <- renderPlot({ residual_plot() })

        # Exportar resultados
        export_server(
            id = "export",
            data = reactive({
                req(forecast_data())
                as.data.frame(forecast_data())
            }),
            plot = arima_plot  # Exportar el gráfico ARIMA
        )
    })
}
