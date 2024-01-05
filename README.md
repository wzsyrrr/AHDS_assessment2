# 3D BMI Relationship Visualization App

## Introduction
This Shiny app visualizes the relationship between Body Mass Index (BMI), poverty income ratio (PIR), and the frequency of eating potato chips using a 3D plot. The app allows users to interactively explore data and input specific values to predict BMI based on the selected frequency of chip consumption and poverty income ratio.

## Features
- Interactive 3D plotting of BMI against chip consumption frequency and PIR.
- User input for prediction of BMI based on specific frequency and PIR.
- Fractional polynomial modeling to handle complex relationships in data.
- Data capping for PIR at a maximum value of 5.

## Requirements
To run this app, you will need R and the following R packages: `shiny`, `dplyr`, `plotly`, and `mfp`. These can be installed using the following R commands:

```R
install.packages(c("shiny", "dplyr", "plotly", "mfp"))
