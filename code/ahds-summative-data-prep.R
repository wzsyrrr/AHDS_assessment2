
## have a look at the nhanes diet, bmi and demographic data, and save to csv
## data from here - https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Examination&CycleBeginYear=2005
## https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Demographics&CycleBeginYear=2005
## https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Dietary&Cycle=2005-2006

## diet questionnaire
library(foreign)
diet <- read.xport("FFQRAW_D.XPT")
head(diet)
write.csv(accel, "FFQRAW_D.csv", row.names=FALSE)

## bmi
bmi <- read.xport("BMX_D.XPT")
head(bmi)
write.csv(bmi, "BMX_D.csv", row.names=FALSE)

# save id and bmi only from BMXBMI data
bmi = bmi[, c('SEQN', 'BMXBMI')]
write.csv(bmi, 'BMI.csv', row.names=FALSE)


## demographics
demo <- read.xport("DEMO_D.XPT")
head(demo)
write.csv(demo, "DEMO_D.csv", row.names=FALSE)
