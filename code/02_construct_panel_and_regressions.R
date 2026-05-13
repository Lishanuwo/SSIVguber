#####################################################################
## Project: Immigration and gubernatorial elections
## Purpose: Process the data exported from the Stata, create new variables, merge datasets, and run regressions
## Author: Lishan Liu
## Date: 2026-05-12
#####################################################################



## import dataset of state immigrant population and state citizen population
rm(list = ls())
library(readxl)
data1 <- read_excel("data/state_year_population.xlsx")
View(data1)

## calculate the state-level immigrant-to-citizen ratio
data1$immiciti_ratio <- data1$immigrant_pop / data1$total_pop

## change the name of states, because the IPUMS dataset shows the short version of state names
library(dplyr)
data1 <- data1 %>%
  mutate(state =case_when(
    state == "californ" ~ "california",
    state == "connecti" ~ "connecticut",
    state == "louisian" ~ "louisiana",
    state == "massachu" ~ "massachusetts",
    state == "minnesot" ~ "minnesota",
    state == "mississi" ~ "mississippi",
    state == "new hamp" ~ "new hampshire",
    state == "new jers" ~ "new jersey",
    state == "new mexi" ~ "new mexico",
    state == "north ca" ~ "north carolina",
    state == "north da" ~ "north dakota",
    state == "pennsylv" ~ "pennsylvania",
    state == "rhode is" ~ "rhode island",
    state == "south ca" ~ "south carolina",
    state == "south da" ~ "south dakota",
    state == "tennesse" ~ "tennessee",
    state == "washingt" ~ "washington",
    state == "west vir" ~ "west virginia",
    state == "wisconsi" ~ "wisconsin",
    TRUE ~ state
  ))

## delete the observations of District of Columbia, Hawaii, Alaska, and Tennessee because of the severe data missing problem for some variables
data1 <- data1 %>%
  filter(state != "district" & state != "hawaii" & state != "alaska" & state != "tennessee")

## extract the state citizen population for the calculations in other data frames
state_pop <- subset(data1, select = c(year, state, total_pop))

## aggregate the state-level citizen and immigrant population to the nation-level
library(dplyr)
data1_nation <- data1 %>%
  group_by(year) %>%
  summarize(
    total_pop = sum(total_pop, na.rm = TRUE),
    immigrant_pop = sum(immigrant_pop, na.rm = TRUE)
)

## calculate the value of the standard instrument: nation-level immigrant-to-citizen ratio
data1_nation$immiciti_ratio <- data1_nation$immigrant_pop / data1_nation$total_pop



## import dataset of state immigrant population from each origin country
library(readxl)
data2 <- read_excel("data/state_year_origin_population.xlsx")
View(data2)             

## change the name of states, because the IPUMS dataset shows the short version of state names
library(dplyr)
data2 <- data2 %>%
  mutate(state =case_when(
    state == "californ" ~ "california",
    state == "connecti" ~ "connecticut",
    state == "louisian" ~ "louisiana",
    state == "massachu" ~ "massachusetts",
    state == "minnesot" ~ "minnesota",
    state == "mississi" ~ "mississippi",
    state == "new hamp" ~ "new hampshire",
    state == "new jers" ~ "new jersey",
    state == "new mexi" ~ "new mexico",
    state == "north ca" ~ "north carolina",
    state == "north da" ~ "north dakota",
    state == "pennsylv" ~ "pennsylvania",
    state == "rhode is" ~ "rhode island",
    state == "south ca" ~ "south carolina",
    state == "south da" ~ "south dakota",
    state == "tennesse" ~ "tennessee",
    state == "washingt" ~ "washington",
    state == "west vir" ~ "west virginia",
    state == "wisconsi" ~ "wisconsin",
    TRUE ~ state
  ))

## delete the observations of District of Columbia, Hawaii, Alaska, and Tennessee because of the severe data missing problem for some variables
data2 <- data2 %>%
  filter(state != "district" & state != "hawaii" & state != "alaska" & state != "tennessee")

## Due to the severity of missing data across many origin countries, I keep the data of the 16 major origin countries 
countries_to_keep <- c("canada", "mexico", "england", "germany", "poland", "china", "japan", "korea", "philippi", "thailand", "india", "africa", "italy", "france", "scotland", "vietnam")
data2 <- data2[data2$bpl %in% countries_to_keep, ]

## Merge the population information from the second data frame into the first data frame.
data2 <-merge(data2, state_pop, by = c("year", "state"), all.x = TRUE) 



## import the dataset of the nation-level immigrant population from each country
library(readxl)
data3 <- read_excel("data/nation_year_origin_population.xlsx")
View(data3)

## keep the data of the 16 major origin countries
data3 <- data3[data3$bpl %in% countries_to_keep, ]

## calculate the "shift" component of the shift-share instrument: the growth rate of each period compared to the base year (2000)
library(dplyr)
data3 <- data3 %>%
  group_by(bpl) %>%
  arrange(year) %>%
  mutate(growth_index = immigrant_pop_in_USA / first(immigrant_pop_in_USA))

## merge the "shift" component into the data2
data2 <- merge(data2, data3, by = c("year", "bpl"), all.x = TRUE)
## calculate the value of shift-share instrument
data2$SSpropo <- data2$immigrants_from_origin_in_state * data2$growth_index / data2$total_pop
data2_allorigin <- data2 %>%
  group_by(year, state) %>%
  summarise(ShiftShare = sum(SSpropo, na.rm = TRUE),
  .groups = "drop"          
            )



## import dataset of regional income per capita
library(readxl)
library(dplyr)
library(tidyr)
income_data <- read_excel("data/income_data.xlsx")

## transform the income_data data frame into a panel data
panel <- income_data %>%
  select(GeoName, `1998`:`2024`) %>%  
  pivot_longer(
    cols = -GeoName,
    names_to = "year",
    values_to = "income_pc"
  ) %>%
  mutate(year = as.integer(year))

## extract the information of the U.S. income per capita
us_income <- panel %>%
  filter(GeoName == "United States") %>%
  select(year, us_income_pc = income_pc)

## generate the state-year panel
state_panel <- panel %>%
  filter(GeoName != "United States") %>%
  left_join(us_income, by = "year") %>%
  arrange(GeoName, year) %>%
  group_by(GeoName) %>%
  mutate(
    income_growth = income_pc / lag(income_pc) -1,
    income_us_ratio = income_pc / us_income_pc
  ) %>%
  ungroup() %>%
  select(
    state = GeoName,
    year,
    income_growth,
    income_us_ratio
  )

## unify the information of the state list and the state names
library(dplyr)
state_panel <- state_panel %>%
  mutate(
    state = tolower(trimws(state))
    )
state_panel <- state_panel %>%
  filter(state != "district of columbia" & state != "hawaii" & state != "alaska" & state != "tennessee")



## import the voting data
library(readxl)
voting_data <- read_excel("data/voting_data.xlsx")
View(voting_data)

## unify the information of the state list and the state names
library(dplyr)
voting_data <- voting_data %>%
  mutate(
    state = tolower(trimws(state))
    )
voting_data <- voting_data %>%
  filter(state != "tennessee")



## lag some independent variables before merging all the datasets
data1_processed <- data1 %>%
  arrange(state, year) %>%
  group_by(state) %>%
  mutate(
    lag_immiciti_ratio = lag(immiciti_ratio, n =1)
  ) %>%
  ungroup() %>%
  select(state, year, lag_immiciti_ratio)

data2_processed <- data2_allorigin %>%
  arrange(state, year) %>%
  group_by(state) %>%
  mutate(
    lag_ShiftShare = lag(ShiftShare, n = 1)
  ) %>%
  ungroup()

data1_nation <- data1_nation %>%
  arrange(year) %>%
  mutate(
    lag_nationimmiratio = lag(immiciti_ratio, 1)
  )
data1_nation <- subset(data1_nation, select = -total_pop)
data1_nation <- subset(data1_nation, select = -immigrant_pop)

statepanel_processed <- state_panel %>%
  arrange(state, year) %>%
  group_by(state) %>%
  mutate(
    lag_incomegrowth = lag(income_growth),
    lag_incomeratio = lag(income_us_ratio)
         ) %>%
  ungroup() %>%
  select(state, year, lag_incomegrowth, lag_incomeratio)



## merge the relevant data frames, construct the panel data for regression, change some variable names, and delete observations with missing data
regression_panel <- voting_data
regression_panel <- merge(regression_panel, data1_processed, by = c("year", "state"), all.x = TRUE)
regression_panel <- merge(regression_panel, data2_processed, by = c("year", "state"), all.x = TRUE)
regression_panel <- merge(regression_panel, statepanel_processed, by = c("year", "state"), all.x = TRUE)
regression_panel <- regression_panel %>%
  left_join(data1_nation, by = "year")
regression_panel <- regression_panel %>%
  rename(demoper = `demopercent(t)`,
         morethant = `dummyformorethantwo(t)`)
regression_panel <- na.omit(regression_panel)



## run OLS regressions
model1 <- lm(demoper ~ lag_immiciti_ratio, data = regression_panel)
summary(model1)
model2 <- lm(demoper ~ lag_immiciti_ratio + lag_incomegrowth + lag_incomeratio + morethant, data = regression_panel)
summary(model2)
model3 <- lm(demoper ~ lag_immiciti_ratio + lag_incomegrowth + lag_incomeratio + morethant + factor(state) + factor(year), data = regression_panel)
summary(model3)



## use the national immigration as the instrument variable
first_stage1 <- lm(lag_immiciti_ratio ~ lag_nationimmiratio, data = regression_panel)
summary(first_stage1)
first_stage2 <- lm(lag_immiciti_ratio ~ lag_nationimmiratio + lag_incomegrowth + lag_incomeratio + morethant, data = regression_panel)
summary(first_stage2)
first_stage3 <- lm(lag_immiciti_ratio ~ lag_nationimmiratio + lag_incomegrowth + lag_incomeratio + morethant + factor(state) + factor(year), data = regression_panel)
summary(first_stage3)



## use the shift-share instrument method
stage1_ssiv1 <- lm(lag_immiciti_ratio ~ lag_ShiftShare, data = regression_panel)
summary(stage1_ssiv1)
stage1_ssiv2 <- lm(lag_immiciti_ratio ~ lag_ShiftShare + lag_incomegrowth + lag_incomeratio + morethant, data = regression_panel)
summary(stage1_ssiv2)
stage1_ssiv3 <- lm(lag_immiciti_ratio ~ lag_ShiftShare + lag_incomegrowth + lag_incomeratio + morethant + factor(state) + factor(year), data = regression_panel)
summary(stage1_ssiv3)

regression_panel$fittedvalue1 <- fitted(stage1_ssiv1)
regression_panel$fittedvalue2 <- fitted(stage1_ssiv2)
regression_panel$fittedvalue3 <- fitted(stage1_ssiv3)

stage2_ssiv1 <- lm(demoper ~ fittedvalue1, data = regression_panel)
summary(stage2_ssiv1)
stage2_ssiv2 <- lm(demoper ~ fittedvalue2 + lag_incomegrowth + lag_incomeratio + morethant, data = regression_panel)
summary(stage2_ssiv2)
stage2_ssiv3 <- lm(demoper ~ fittedvalue3 + lag_incomegrowth + lag_incomeratio + morethant + factor(state) + factor(year), data = regression_panel)
summary(stage2_ssiv3)
                                    