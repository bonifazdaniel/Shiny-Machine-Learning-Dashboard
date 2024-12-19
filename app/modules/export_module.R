# export_module.R
library(gridExtra)

# UI para exportar resultados
export_ui <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Export Options"),
        downloadButton(ns("export_csv"), "Export to CSV"), # Botón para exportar CSV
        downloadButton(ns("export_pdf"), "Export to PDF")  # Botón para exportar PDF
    )
}

# Server del módulo para exportación
export_server <- function(id, data, plot = NULL) {
    moduleServer(id, function(input, output, session) {
        # Exportar a CSV
        output$export_csv <- downloadHandler(
            filename = function() {
                paste0("exported_data_", Sys.Date(), ".csv")
            },
            content = function(file) {
                req(data())  # Verificar que los datos estén disponibles
                write.csv(data(), file, row.names = FALSE)
            }
        )

        # Exportar a PDF
        output$export_pdf <- downloadHandler(
            filename = function() {
                paste0("exported_plot_", Sys.Date(), ".pdf")
            },
            content = function(file) {
                req(data())  # Verificar que los datos estén disponibles
                pdf(file, width = 8, height = 6)  # Tamaño del PDF
                if (!is.null(plot)) {
                    print(plot())  # Imprimir gráfico si está disponible
                } else {
                    grid.table(data())  # Imprimir tabla si no hay gráfico
                }
                dev.off()  # Finalizar archivo PDF
            }
        )
    })
}
