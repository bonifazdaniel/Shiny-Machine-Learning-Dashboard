# clustering_module.R
library(ggplot2)

# UI del módulo para controles (inputs)
clustering_inputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Clustering Controls"),
        selectInput(ns("x_var"), "Select X Variable", choices = NULL),
        selectInput(ns("y_var"), "Select Y Variable", choices = NULL),
        numericInput(ns("clusters"), "Number of Clusters (k)", value = 3, min = 2),
        actionButton(ns("run_clustering"), "Run Clustering")
    )
}

# UI del módulo para salidas (outputs)
clustering_outputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Clustering Results"),
        plotOutput(ns("cluster_plot"), height = "400px"),
        hr(),
        export_ui(ns("export"))  # Botones para exportar resultados
    )
}

# Server del módulo para análisis de clustering
clustering_server <- function(id, data) {
    moduleServer(id, function(input, output, session) {
        clustering_result <- reactiveVal(NULL)  # Guardar los resultados del clustering
        
        # Actualizar las opciones de variables
        observe({
            req(data())
            numeric_vars <- names(data())[sapply(data(), is.numeric)]
            updateSelectInput(session, "x_var", choices = numeric_vars, selected = numeric_vars[1])
            updateSelectInput(session, "y_var", choices = numeric_vars, selected = numeric_vars[2])
        })

        # Ejecutar el clustering
        observeEvent(input$run_clustering, {
            req(input$x_var, input$y_var, data())
            df <- data()[, c(input$x_var, input$y_var)]
            colnames(df) <- c("X", "Y")

            # Aplicar K-means clustering
            kmeans_result <- kmeans(df, centers = input$clusters)
            df$Cluster <- as.factor(kmeans_result$cluster)  # Agregar etiquetas de clusters
            clustering_result(df)
        })

        # Gráfico de clustering
        cluster_plot <- reactive({
            req(clustering_result())
            ggplot(clustering_result(), aes(x = X, y = Y, color = Cluster)) +
                geom_point(size = 3) +
                labs(
                    title = "Clustering Results",
                    x = input$x_var,
                    y = input$y_var
                ) +
                theme_minimal() +
                scale_color_brewer(palette = "Set1")
        })

        output$cluster_plot <- renderPlot({ cluster_plot() })

        # Exportar resultados
        export_server(
            id = "export",
            data = reactive({
                req(clustering_result())
                clustering_result()
            }),
            plot = cluster_plot  # Exportar el gráfico de clustering
        )
    })
}
