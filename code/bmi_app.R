#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readr)
library(ggplot2)
library(dplyr)
library(rms)

# Read data
survey_data <- read_csv("../clean/bmi_model_dt.csv")

# Define the user interface
ui <- fluidPage(
  titlePanel("BMI Odds by Potato Chips Consumption and Poverty Income Ratio"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("PIRRange", "Select Poverty Income Ratio Range:",
                  min = min(survey_data$INDFMPIR, na.rm = TRUE), 
                  max = max(survey_data$INDFMPIR, na.rm = TRUE), 
                  value = c(min(survey_data$INDFMPIR, na.rm = TRUE), max(survey_data$INDFMPIR, na.rm = TRUE))),
      selectInput("frequency", "Frequency of Eating Potato Chips:",
                  choices = c("Never" = 1, "1-6 times per year" = 2, "7-11 times per year" = 3,
                              "1 time per month" = 4, "2-3 times per month" = 5, "1 time per week" = 6,
                              "2 times per week" = 7, "3-4 times per week" = 8, "5-6 times per week" = 9,
                              "1 time per day" = 10, "2 or more times per day" = 11)),
      selectInput("PIR_5", "Select Poverty Income Ratio Group:",
                  choices = c("<1" = 0, ">=1 and <2" = 1, ">=2 and <4" = 2, ">=4" = 4))
    ),
    mainPanel(
      plotOutput("BMIPlot"),
      textOutput("specificOdds")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Reactive expression for the plot based on the selected PIR range
  output$BMIPlot <- renderPlot({
    filtered_data <- survey_data %>% 
      filter(INDFMPIR >= as.numeric(input$PIRRange[1]) & INDFMPIR <= as.numeric(input$PIRRange[2]))
    if(nrow(filtered_data) > 0) {
      fit <- glm(bmi ~ as.factor(FFQ0102) + INDFMPIR, data = filtered_data, family = binomial(link = "logit"))
      new_data <- data.frame(FFQ0102 = unique(filtered_data$FFQ0102), INDFMPIR = mean(as.numeric(input$PIRRange)))
      predictions <- data.frame(FFQ0102 = new_data$FFQ0102, PredictedOdds = exp(predict(fit, newdata = new_data, type = "response")))
      
      ggplot(predictions, aes(x = FFQ0102, y = PredictedOdds)) +
        geom_line() +
        geom_point(data = filtered_data, aes(x = FFQ0102, y = ifelse(bmi == 1, 1, 0)), color = "red", alpha = 0.3) +
        scale_x_continuous(breaks = 1:11, labels = c("Never", "1-6 times per year", "7-11 times per year", "1 time per month", "2-3 times per month",
                                                     "1 time per week", "2 times per week", "3-4 times per week", "5-6 times per week", "1 time per day", "2 or more times per day")) +
        labs(x = "Frequency of Eating Potato Chips", y = "Predicted Odds of BMI >= 25") +
        theme_minimal() +
        ggtitle("BMI Odds by Frequency of Potato Chip Consumption and Poverty Income Ratio")
    } else {
      print("Not enough data to fit the model. Please select a different range.")
    }
  })
  
  # Reactive expression for calculating specific odds
  output$specificOdds <- renderText({
    specific_data <- survey_data %>% 
      filter(FFQ0102 == as.numeric(input$frequency) & PIR_5 == as.numeric(input$PIR_5))
      fit_specific <- glm(bmi ~ as.factor(FFQ0102) + as.factor(PIR_5), data = specific_data, family = binomial(link = "logit"))
      predicted_specific_odds <- exp(predict(fit_specific(), newdata = specific_data, type = "response"))
      paste("The estimated odds for the selected frequency and PIR group is:", predicted_specific_odds)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)