library(dplyr)

#read BMI.csv data
dt_bmi <- read.csv("../raw/BMI.csv")
head(dt_bmi)


#read DEMO_D.csv data
dt_demo <- read.csv("../raw/DEMO_D.csv")
head(dt_demo)


#read data FFQRAW_D.csv
dt_ffq <- read.csv("../raw/FFQRAW_D.csv")
head(dt_ffq)

#combine three data sets
research_dt <- merge(dt_bmi, dt_demo, by = "SEQN")
research_dt <- merge(research_dt, dt_ffq, by = "SEQN")
head(research_dt)

#slect the data I want to use
research_dt_clean <- subset(research_dt, select=c("SEQN", "BMXBMI", "INDFMPIR", "FFQ0102"))

#remove all rows for which frequency of eating potato chips is blank or error
research_dt_clean <- subset(research_dt_clean, FFQ0102 != "88" & FFQ0102 != "99")

#remove all NA rows
research_dt_clean <- na.omit(research_dt_clean)
table(research_dt_clean$FFQ0102)

#remove the outlier with BMI = 130
research_dt_clean <- subset(research_dt_clean, BMXBMI < 100)

#output clean data
write.csv(research_dt_clean,"../clean/clean.csv", row.names = FALSE)

