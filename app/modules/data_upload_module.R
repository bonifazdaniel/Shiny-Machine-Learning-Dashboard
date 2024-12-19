# data_upload_module.R
library(DT)

# UI del módulo para carga de datos
data_upload_ui <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Upload Dataset"),
        fileInput(ns("file_upload"), "Choose CSV File",
                  accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
        checkboxInput(ns("header"), "Header", TRUE),
        selectInput(ns("separator"), "Separator", choices = c("Comma" = ",", "Semicolon" = ";", "Tab" = "\t"), selected = ","),
        checkboxInput(ns("show_data"), "Display Uploaded Data (Optional)", FALSE), # Control para mostrar u ocultar
        hr(),
        conditionalPanel(
            condition = paste0("input['", ns("show_data"), "'] == true"),
            DTOutput(ns("data_table")) # Tabla interactiva condicional
        )
    )
}

# Server del módulo para carga de datos
data_upload_server <- function(id) {
    moduleServer(id, function(input, output, session) {
        uploaded_data <- reactiveVal(NULL)  # Guardar los datos cargados
        
        # Leer los datos cargados
        observeEvent(input$file_upload, {
            req(input$file_upload)
            data <- tryCatch(
                {
                    read.csv(input$file_upload$datapath, 
                             header = input$header, 
                             sep = input$separator)
                },
                error = function(e) {
                    showNotification("Error in file upload: Invalid format or corrupted file.", type = "error")
                    NULL
                }
            )
            uploaded_data(data)
            showNotification("File uploaded successfully!", type = "message")
        })

        # Mostrar la tabla interactiva solo si está habilitado
        output$data_table <- renderDT({
            req(uploaded_data(), input$show_data)
            datatable(uploaded_data(), options = list(pageLength = 5, autoWidth = TRUE))
        })

        # Retornar los datos cargados
        return(uploaded_data)
    })
}
