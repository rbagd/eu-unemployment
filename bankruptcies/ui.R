library(shiny)

shinyUI(fluidPage(
  titlePanel("Faillites d'entreprises en Belgique"),

  sidebarLayout(
         sidebarPanel(
              fluidRow(
                column(9,
                       "Disponibilité des données entre ", textOutput("firstdata", inline=TRUE),
                       " et ", textOutput("lastdata", inline=TRUE),
                       br(),
                       br(),
                       sliderInput("month", "Sélectionnez le mois dans cet intervalle: ", 1, 13, 13, 1, animate=TRUE),
                       checkboxInput("capita", "Faillites par habitant", FALSE) ),
                column(12,
                       dataTableOutput("summary")
                       ))),
         mainPanel(
                plotOutput("mapplot", width="100%")
    )
  )
))
