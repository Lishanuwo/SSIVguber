/********************************************************************
Project: Immigration and gubernatorial elections
Purpose: Aggregate IPUMS microdata into state-year, state-year-origin, and nation-year-origin panel datasets and construct immigration-related variables
Author: Lishan Liu
Date: 2026-05-12
********************************************************************/

## First, I download the population microdata from the Integrated Public Use Microdata Series (IPUMS) for the years 2000 to 2023. The relevant variables include year (census year), statefip (state fip code), perwt (person weight), bpl (birthplace), and citizen (citizenship status). I save the microdata as a Stata file named “data.dta”.
## Calculate the citizen population and naturalized immigrant population in each state; the result is exported to the Excel file “state_year_population_xlsx”.
use “data”
gen immigrant = (citizen == 2)
gen wt = perwt
preserve
collapse (sum) total_pop = wt, by(year statefip)
save total_pop_by_state_year.dta, replace
restore
keep if immigrant == 1
collapse (sum) immigrant_pop = wt, by(year statefip)
save immigrant_pop_by_state_year.dta, replace

## Calculate immigrant population from each country in each state; the result is exported to the Excel file “state_year_origin_population.xlsx”.
clear
use "data" 
drop if citizen > 2
gen immigrant = (citizen == 2)
gen wt = perwt
keep if immigrant == 1
collapse (sum) immigrants_from_country = wt, by(year statefip bpl)
save immigrants_by_state_year_country.dta, replace

## Calculate immigrant population from each country in USA; the result is exported to the Excel file “national_year_origin_population.xlsx”.
collapse (sum) immigrants_national = immigrants_from_country, by(year bpl)
save immigrants_by_year_country_national.dta, replace