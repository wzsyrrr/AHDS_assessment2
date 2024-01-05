#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(plotly)
library(mfp)

# Read data
survey_data <- read.csv("../clean/bmi_model_dt.csv")

# Define the user interface
survey_data$INDFMPIR <- pmin(survey_data$INDFMPIR, 5)  # Limit INDFMPIR to a maximum of 5

# Define the user interface
ui <- fluidPage(
  titlePanel("3D Relationship of BMXBMI, Poverty Income Ratio, and Frequency of Eating Potato Chips"),
  sidebarLayout(
    sidebarPanel(
      # Add a table to describe the frequency of eating potato chips
      h4("Frequency of Eating Potato Chips:"),
      tags$table(class = "table table-striped",
                 tags$thead(
                   tags$tr(tags$th("Code"), tags$th("Value Description"))
                 ),
                 tags$tbody(
                   tags$tr(tags$td("1"), tags$td("Never")),
                   tags$tr(tags$td("2"), tags$td("1-6 times per year")),
                   tags$tr(tags$td("3"), tags$td("7-11 times per year")),
                   tags$tr(tags$td("4"), tags$td("1 time per month")),
                   tags$tr(tags$td("5"), tags$td("2-3 time per month")),
                   tags$tr(tags$td("6"), tags$td("1 time per week")),
                   tags$tr(tags$td("7"), tags$td("2 time per week")),
                   tags$tr(tags$td("8"), tags$td("3-4 time per week")),
                   tags$tr(tags$td("9"), tags$td("5-6 time per week")),
                   tags$tr(tags$td("10"), tags$td("1 time per day")),
                   tags$tr(tags$td("11"), tags$td("2 or more times per day"))
                 )
      ),
      
      numericInput("inputFrequency", "Please select your frequency of eating potato chips:", min = 1, max = 11, value = 1),
      numericInput("inputPIR", "Please enter your Poverty Income Ratio:", min = 0, max = 5, value = 0),
      actionButton("predict", "Predict")
    ),
    mainPanel(
      plotlyOutput("Plot3D"),
      textOutput("predictedBMI")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
    # Reactive data loading
    survey_data <- reactive({
      data <- read.csv("../clean/bmi_model_dt.csv")
      data$INDFMPIR <- pmin(data$INDFMPIR, 5)  # Limit INDFMPIR to a maximum of 5
      data
    })
    
    # Reactive model fitting
    fit <- reactive({
      mfp(BMXBMI ~ fp(FFQ0102, df=2) + INDFMPIR, data = survey_data(), family = gaussian)
    })
    
    # Generate the 3D plot
    output$Plot3D <- renderPlotly({
      plot_data <- survey_data() %>% 
        select(FFQ0102, INDFMPIR, BMXBMI)
      
      p <- plot_ly(plot_data, x = ~FFQ0102, y = ~INDFMPIR, z = ~BMXBMI, type = 'scatter3d', mode = 'markers',
                   marker = list(color = 'blue', size = 1), name = 'Population Data') %>%
        layout(title = "3D Relationship of BMXBMI, PIR, and Frequency of Eating Chips",
               scene = list(xaxis = list(title = 'Frequency of Eating Chips'),
                            yaxis = list(title = 'Poverty Income Ratio (Capped at 5)'),
                            zaxis = list(title = 'BMXBMI')),
               legend = list(x = 0.9, y = 0.1, orientation = 'h'))
      p
    })
    
    # Predict and label the point on the plot
    observeEvent(input$predict, {
      new_data <- data.frame(FFQ0102 = input$inputFrequency, INDFMPIR = pmin(input$inputPIR, 5))
      predicted_value <- predict(fit(), newdata = new_data, type = "response")
      
      output$predictedBMI <- renderText({
        paste("Predicted BMI for Potato Chips Consumption Group:", input$inputFrequency, "and Poverty Income Ratio:", input$inputPIR, "is:", predicted_value)
      })
      
      # Update the plot with the predicted point
      output$Plot3D <- renderPlotly({
        plot_data <- survey_data() %>% 
          select(FFQ0102, INDFMPIR, BMXBMI)
        
        p <- plot_ly(plot_data, x = ~FFQ0102, y = ~INDFMPIR, z = ~BMXBMI, type = 'scatter3d', mode = 'markers',
                     marker = list(color = 'blue', size = 1), name = 'Population Data') %>%
          add_trace(x = c(input$inputFrequency), y = c(input$inputPIR), z = c(predicted_value),
                    type = 'scatter3d', mode = 'markers',
                    marker = list(color = 'red', size = 3), name = 'Predicted Data') %>%
          layout(title = "3D Relationship of BMXBMI, PIR, and Frequency of Eating Chips",
                 scene = list(xaxis = list(title = 'Frequency of Eating Chips'),
                              yaxis = list(title = 'Poverty Income Ratio (Capped at 5)'),
                              zaxis = list(title = 'BMXBMI')),
                 legend = list(x = 0.9, y = 0.1, orientation = 'h'))
        p
      })
    })
  }
# Run the application 
shinyApp(ui = ui, server = server)