library(shiny)

shinyUI(fluidPage(
  titlePanel("Faillites d'entreprises en Belgique"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("month", "Date", 3, 13, 13, 1, animate=TRUE),
      checkboxInput("capita", "Per capita", FALSE)
    ),
    mainPanel(
      plotOutput("mapplot"),
      tableOutput("summary")
    )
  )
))