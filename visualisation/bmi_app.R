#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Load package 
library(shiny)
library(dplyr)
library(plotly)
library(mfp)


# Read data
survey_data <- read.csv("../clean/clean.csv")


# Define the user interface, user can enter their poverty income ratio
# Limit INDFMPIR to a maximum of 5, all enter greater than 5 will be treated as 5
survey_data$INDFMPIR <- pmin(survey_data$INDFMPIR, 5) 


# Define the user interface, user can choose their potato chips consumption groups
ui <- fluidPage(
  # Add a title
  titlePanel("3D Relationship of BMXBMI, Poverty Income Ratio, and Frequency of Eating Potato Chips"),
  sidebarLayout(
    # Define a sidebar panel for user to enter their condition
    sidebarPanel(
      # Add a table to describe the frequency of eating potato chips
      h4("Frequency of Eating Potato Chips:"),
      tags$table(class = "table table-striped",
                 tags$thead(
                   tags$tr(tags$th("Group"), tags$th("Potato Chips Consumption Frequency"))
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
      # Numeric input for potato chips consumption frequency groups and poverty income ratio 
      numericInput("inputFrequency", "Please select your frequency of eating potato chips:", min = 1, max = 11, value = 1),
      numericInput("inputPIR", "Please enter your Poverty Income Ratio:", min = 0, max = 5, value = 0),
      # Add a button, when user click button app will predict
      actionButton("predict", "Predict")
    ),
    # Main panel to display the 3D plot and predicted BMI output
    mainPanel(
      plotlyOutput("Plot3D"),
      textOutput("predictedBMI")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
    # Reactive data, so that data can load and process automatically
    survey_data <- reactive({
      data <- read.csv("../clean/clean.csv")
      data$INDFMPIR <- pmin(data$INDFMPIR, 5)  
      data
    })
    
    # Reactive model fitting, so model will fit automatically
    fit <- reactive({
      mfp(BMXBMI ~ fp(FFQ0102, df=2) + INDFMPIR, data = survey_data(), family = gaussian)
    })
    
    # Generate the 3D plot
    output$Plot3D <- renderPlotly({
      plot_data <- survey_data() %>% 
        select(FFQ0102, INDFMPIR, BMXBMI)
      
      # Create the 3D scatter plot
      p <- plot_ly(plot_data, x = ~FFQ0102, y = ~INDFMPIR, z = ~BMXBMI, type = 'scatter3d', mode = 'markers',
                   marker = list(color = 'blue', size = 1), name = 'Population Data') %>%
        layout(title = "3D Relationship of BMXBMI, PIR, and Frequency of Eating Chips",
               scene = list(xaxis = list(title = 'Frequency of Eating Chips'),
                            yaxis = list(title = 'Poverty Income Ratio (Capped at 5)'),
                            zaxis = list(title = 'BMXBMI')),
               # Update the 3D plot with the predicted point
               legend = list(x = 0.9, y = 0.1, orientation = 'h'))
      p
    })
    
    # Predict and label the point on the plot
    observeEvent(input$predict, {
      # Create new data for prediction based on user input
      new_data <- data.frame(FFQ0102 = input$inputFrequency, INDFMPIR = pmin(input$inputPIR, 5))
      # Perform prediction using the fitted model
      predicted_value <- predict(fit(), newdata = new_data, type = "response")
      
      # Display the predicted BMI in the UI
      output$predictedBMI <- renderText({
        paste("Predicted BMI for Potato Chips Consumption Group:", input$inputFrequency, "and Poverty Income Ratio:", input$inputPIR, "is:", predicted_value)
      })
      
      # Update the plot with the predicted point
      output$Plot3D <- renderPlotly({
        plot_data <- survey_data() %>% 
          select(FFQ0102, INDFMPIR, BMXBMI)
        
        # Add the predicted point to the existing plot
        p <- plot_ly(plot_data, x = ~FFQ0102, y = ~INDFMPIR, z = ~BMXBMI, type = 'scatter3d', mode = 'markers',
                     marker = list(color = 'blue', size = 1), name = 'Population Data') %>%
          add_trace(x = c(input$inputFrequency), y = c(input$inputPIR), z = c(predicted_value),
                    type = 'scatter3d', mode = 'markers',
                    marker = list(color = 'red', size = 3), name = 'Predicted Data') %>%
          layout(title = "3D Relationship of BMXBMI, PIR, and Frequency of Eating Chips",
                 scene = list(xaxis = list(title = 'Frequency of Eating Chips'),
                              yaxis = list(title = 'Poverty Income Ratio (Capped at 5)'),
                              zaxis = list(title = 'BMXBMI')),
                 # Position the legend at the bottom right
                 legend = list(x = 0.9, y = 0.1, orientation = 'h'))
        #return p
        p
      })
    })
  }
# Run app 
shinyApp(ui = ui, server = server)