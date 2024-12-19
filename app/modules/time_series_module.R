# time_series_module.R
library(ggplot2)
library(forecast)

# UI del módulo para controles (inputs)
time_series_inputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Time Series Analysis"),
        selectInput(ns("time_var"), "Select Time Variable", choices = NULL),
        selectInput(ns("value_var"), "Select Value Variable", choices = NULL),
        numericInput(ns("forecast_horizon"), "Forecast Horizon (steps)", value = 10, min = 1),
        actionButton(ns("analyze_series"), "Analyze Time Series")
    )
}

# UI del módulo para salidas (outputs)
time_series_outputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Time Series Plot"),
        plotOutput(ns("time_series_plot"), height = "400px"),
        hr(),
        h4("Forecast Plot"),
        plotOutput(ns("forecast_plot"), height = "400px"),
        hr(),
        export_ui(ns("export"))  # Botones para exportar resultados
    )
}

# Server del módulo para análisis de series temporales
time_series_server <- function(id, data) {
    moduleServer(id, function(input, output, session) {
        ts_data <- reactiveVal(NULL)       # Guardar los datos de la serie temporal
        forecast_result <- reactiveVal(NULL) # Guardar el resultado del pronóstico
        
        # Actualizar las opciones de variables
        observe({
            req(data())
            vars <- names(data())
            updateSelectInput(session, "time_var", choices = vars)
            updateSelectInput(session, "value_var", choices = vars)
        })

        # Análisis de la serie temporal
        observeEvent(input$analyze_series, {
            req(input$time_var, input$value_var, data())
            df <- data()[, c(input$time_var, input$value_var)]
            colnames(df) <- c("Time", "Value")
            
            # Convertir la columna de tiempo a Date
            df$Time <- as.Date(df$Time, format = "%Y-%m-%d")
            df <- df[order(df$Time), ]
            
            # Crear la serie temporal
            ts_obj <- ts(df$Value, frequency = 12)  # Frecuencia mensual
            ts_data(ts_obj)
            
            # Realizar el pronóstico
            forecast_result(forecast(ts_obj, h = input$forecast_horizon))
        })

        # Gráfico de la serie temporal
        time_series_plot <- reactive({
            req(ts_data())
            autoplot(ts_data()) +
                labs(title = "Time Series Plot", x = "Time", y = "Value") +
                theme_minimal()
        })

        output$time_series_plot <- renderPlot({ time_series_plot() })

        # Gráfico del pronóstico
        forecast_plot <- reactive({
            req(forecast_result())
            autoplot(forecast_result()) +
                labs(title = "Forecast Plot", x = "Time", y = "Value") +
                theme_minimal()
        })

        output$forecast_plot <- renderPlot({ forecast_plot() })

        # Exportar resultados
        export_server(
            id = "export",
            data = reactive({
                req(forecast_result())
                as.data.frame(forecast_result())
            }),
            plot = forecast_plot  # Exportar el gráfico del pronóstico
        )
    })
}
