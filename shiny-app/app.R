# -----------------------------------------------------------------------
# Domino Data Lab - Demo Shiny App
# -----------------------------------------------------------------------
# A minimal Shiny application used to validate the R/Shiny side of the
# DAVNIC migration pipeline: Workspace -> Environment -> Published App.
#
# Unlike Dash, Shiny does NOT need a manual pathname-prefix fix — Domino's
# App proxy handles Shiny's relative asset paths and WebSocket upgrade
# natively. host = "0.0.0.0" and port = 8888 are the only requirements.
# -----------------------------------------------------------------------

library(shiny)
library(ggplot2)

# --- Sample data ---------------------------------------------------------
df <- data.frame(
  Category = c("Compute", "Storage", "Model Registry", "Flows", "Apps"),
  Usage = c(42, 18, 27, 12, 35)
)

# --- UI --------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Domino Platform Demo App (Shiny)"),
  p("This app is running inside a Domino Workspace / App. Use it to confirm
     your R environment, port, and app.sh setup work."),
  checkboxGroupInput(
    inputId = "category_filter",
    label = "Categories",
    choices = df$Category,
    selected = df$Category,
    inline = TRUE
  ),
  plotOutput("usage_plot"),
  verbatimTextOutput("env_info")
)

# --- Server ------------------------------------------------------------
server <- function(input, output, session) {

  output$usage_plot <- renderPlot({
    filtered <- df[df$Category %in% input$category_filter, ]
    ggplot(filtered, aes(x = Category, y = Usage)) +
      geom_col(fill = "#4C78A8") +
      labs(title = "Sample Domino Resource Usage") +
      theme_minimal()
  })

  output$env_info <- renderText({
    project <- Sys.getenv("DOMINO_PROJECT_NAME", unset = "N/A")
    run_id  <- Sys.getenv("DOMINO_RUN_ID", unset = "N/A")
    user    <- Sys.getenv("DOMINO_STARTING_USERNAME", unset = "N/A")
    sprintf("Domino Project: %s | Run ID: %s | User: %s", project, run_id, user)
  })
}

# --- Launch --------------------------------------------------------------
# host/port are set by app.sh via shiny::runApp(), per Domino's documented
# pattern, so this file stays portable between local testing and Domino.
shinyApp(ui = ui, server = server)
