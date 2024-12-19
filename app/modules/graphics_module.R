# graphics_module.R
library(ggplot2)

# UI del módulo para controles (inputs)
graphics_inputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Graphics Controls"),
        selectInput(ns("x_var"), "Select X Variable", choices = NULL),
        selectInput(ns("y_var"), "Select Y Variable (Optional)", choices = c("None" = NULL)),
        radioButtons(ns("graph_type"), "Graph Type", choices = c("Histogram", "Scatter Plot")),
        actionButton(ns("generate_graph"), "Generate Graph")
    )
}

# UI del módulo para salidas (outputs)
graphics_outputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Generated Graph"),
        plotOutput(ns("graph_plot"), height = "400px"),
        hr(),
        export_ui(ns("export"))  # Botones para exportar gráficos
    )
}

# Server del módulo para generación de gráficos
graphics_server <- function(id, data) {
    moduleServer(id, function(input, output, session) {
        generated_graph <- reactiveVal(NULL)  # Guardar el gráfico generado
        
        # Actualizar las opciones de variables
        observe({
            req(data())
            numeric_vars <- names(data())[sapply(data(), is.numeric)]
            updateSelectInput(session, "x_var", choices = numeric_vars, selected = numeric_vars[1])
            updateSelectInput(session, "y_var", choices = c("None" = NULL, numeric_vars), selected = NULL)
        })

        # Generar el gráfico según la selección
        observeEvent(input$generate_graph, {
            req(input$x_var, data())
            df <- data()
            
            if (input$graph_type == "Histogram") {
                # Generar histograma
                plot <- ggplot(df, aes_string(x = input$x_var)) +
                    geom_histogram(binwidth = 30, fill = "steelblue", color = "black") +
                    labs(
                        title = paste("Histogram of", input$x_var),
                        x = input$x_var,
                        y = "Frequency"
                    ) +
                    theme_minimal()
            } else if (input$graph_type == "Scatter Plot" && !is.null(input$y_var)) {
                # Generar gráfico de dispersión
                plot <- ggplot(df, aes_string(x = input$x_var, y = input$y_var)) +
                    geom_point(color = "darkred", size = 2) +
                    labs(
                        title = "Scatter Plot",
                        x = input$x_var,
                        y = input$y_var
                    ) +
                    theme_minimal()
            } else {
                plot <- NULL
            }
            
            generated_graph(plot)  # Guardar el gráfico generado
        })

        # Renderizar el gráfico generado
        output$graph_plot <- renderPlot({
            req(generated_graph())
            generated_graph()
        })

        # Exportar el gráfico
        export_server(
            id = "export",
            data = reactive({
                req(data())
                data()
            }),
            plot = generated_graph  # Exportar el gráfico generado
        )
    })
}
