# data_filter_module.R
library(DT)        # Para tablas interactivas
library(gridExtra) # Para exportar tablas en PDF

# UI del módulo para filtrado dinámico
data_filter_ui <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Dynamic Data Filter"),
        DTOutput(ns("filtered_table")),         # Tabla interactiva
        hr(),
        h4("Export Filtered Data"),
        downloadButton(ns("export_csv"), "Export to CSV"), # Botón para exportar CSV
        downloadButton(ns("export_pdf"), "Export to PDF")  # Botón para exportar PDF
    )
}

# Server del módulo para filtrado dinámico y exportación
data_filter_server <- function(id, data) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        # Crear datos filtrados
        filtered_data <- reactive({
            req(data())  # Asegurar que los datos estén cargados
            data()
        })

        # Mostrar tabla interactiva con filtrado dinámico
        output$filtered_table <- renderDT({
            req(filtered_data())
            datatable(
                filtered_data(),
                filter = "top",     # Filtros por columna
                extensions = "Buttons",
                options = list(
                    dom = "Bfrtip",
                    buttons = c("copy", "csv", "excel"), # Exportación directa desde la tabla
                    pageLength = 10,                    # Mostrar 10 filas por página
                    autoWidth = TRUE
                )
            )
        })

        # Exportar datos filtrados a CSV
        output$export_csv <- downloadHandler(
            filename = function() {
                paste0("filtered_data_", Sys.Date(), ".csv")
            },
            content = function(file) {
                write.csv(filtered_data(), file, row.names = FALSE)
            }
        )

        # Exportar datos filtrados a PDF
        output$export_pdf <- downloadHandler(
            filename = function() {
                paste0("filtered_data_", Sys.Date(), ".pdf")
            },
            content = function(file) {
                pdf(file, width = 11, height = 8.5) # Tamaño de página (horizontal)
                grid.table(filtered_data())         # Exportar la tabla como PDF
                dev.off()                           # Cerrar el archivo PDF
            }
        )
    })
}
