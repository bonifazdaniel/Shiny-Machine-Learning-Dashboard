# decision_tree_module.R
library(rpart)
library(rpart.plot)
library(ggplot2)

# UI del módulo para controles (inputs)
decision_tree_inputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Decision Tree Controls"),
        selectInput(ns("y_var"), "Select Target Variable (Y)", choices = NULL),
        selectInput(ns("x_vars"), "Select Predictor Variables (X)", choices = NULL, multiple = TRUE),
        radioButtons(ns("tree_type"), "Tree Type", choices = c("Regression", "Classification")),
        actionButton(ns("train_tree"), "Train Decision Tree")
    )
}

# UI del módulo para salidas (outputs)
decision_tree_outputs <- function(id) {
    ns <- NS(id)
    tagList(
        h4("Decision Tree Visualization"),
        plotOutput(ns("tree_plot"), height = "400px"),
        hr(),
        h4("Variable Importance"),
        plotOutput(ns("importance_plot"), height = "300px"),
        hr(),
        export_ui(ns("export"))  # Botones para exportar resultados
    )
}

# Server del módulo para construir el árbol de decisión
decision_tree_server <- function(id, data) {
    moduleServer(id, function(input, output, session) {
        tree_model <- reactiveVal(NULL)  # Guardar el modelo del árbol
        variable_importance <- reactiveVal(NULL)  # Importancia de las variables

        # Actualizar las opciones de variables
        observe({
            req(data())
            vars <- names(data())
            updateSelectInput(session, "y_var", choices = vars, selected = vars[1])
            updateSelectInput(session, "x_vars", choices = vars, selected = vars[-1])
        })

        # Entrenar el modelo del árbol
        observeEvent(input$train_tree, {
            req(input$y_var, input$x_vars, data())
            df <- data()[, c(input$x_vars, input$y_var)]
            colnames(df)[ncol(df)] <- "Y"

            # Ajustar el modelo según el tipo de árbol
            if (input$tree_type == "Classification") {
                df$Y <- as.factor(df$Y)
                model <- rpart(Y ~ ., data = df, method = "class")
            } else {
                model <- rpart(Y ~ ., data = df, method = "anova")
            }

            tree_model(model)
            variable_importance(model$variable.importance)
        })

        # Gráfico del árbol
        tree_plot <- reactive({
            req(tree_model())
            rpart.plot(tree_model(), main = "Decision Tree", box.palette = "Blues")
        })

        output$tree_plot <- renderPlot({ tree_plot() })

        # Gráfico de importancia de variables
        importance_plot <- reactive({
            req(variable_importance())
            importance_df <- data.frame(
                Variable = names(variable_importance()),
                Importance = variable_importance()
            )
            ggplot(importance_df, aes(x = reorder(Variable, Importance), y = Importance)) +
                geom_bar(stat = "identity", fill = "steelblue") +
                coord_flip() +
                labs(title = "Variable Importance", x = "Variables", y = "Importance") +
                theme_minimal()
        })

        output$importance_plot <- renderPlot({ importance_plot() })

        # Exportar resultados
        export_server(
            id = "export",
            data = reactive({
                req(variable_importance())
                data.frame(
                    Variable = names(variable_importance()),
                    Importance = variable_importance()
                )
            }),
            plot = tree_plot  # Exportar el gráfico del árbol
        )
    })
}
