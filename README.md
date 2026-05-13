## Research question
What is the effect of the immigration ratio on the voting share received by Democratic candidates in gubernatorial elections?

## Data sources
(1) immigration-related variables: Integrated Public Use Microdata Series (IPUMS)
(2) income-related variables: the Bureau of Economic Analysis (BEA)
(3) the information about gubernatorial elections: Wikipedia

## Variable definitions
(1) demoper: the dependent variable; the vote share received by a Democratic candidate in a gubernatorial election
(2) lag_immiciti_ratio: the key independent variable; the share of naturalized citizens in a state's citizen population, lagged by one year
(3) lag_nationimmiratio: an instrumental variable; the share of naturalized citizens in the U.S. citizen population, lagged by one year
(4) lag_ShiftShare: the shift-share instrumental variable; the difinition is shown in the paper
(5) lag_incomegrowth: the per capita personal income growth rate, lagged by one year
(6) lag_incomeratio: the ratio of state per capital personal income to national per capita personal income
(7) morethant: a binary indicator equal to 1 if there were more than two gubernatorial candidates

## Folder Structure
SSIVguber/
├── data/
│   ├── state_year_population.xlsx
│   ├── state_year_origin_population.xlsx
│   └── nation_year_origin_population.xlsx
├── code/
│   ├── 01_aggregate_ipums.do
│   └── 02_construct_panel_and_regressions.R
├── paper/
│   └── SSIV_gubernatorial_elections_paper.pdf
└── README.md

## How to reproduce
（1）Download the IPUMS population microdata (approximately 77 million observations) for the years 2000–2023 from the Integrated Public Use Microdata Series (IPUMS).
（2）Run the Stata script `01_aggregate_ipums.do` to aggregate the microdata and construct:
   - the citizen population and naturalized immigrant population in each state-year,
   - the immigrant population from each origin country in each state-year,
   - the immigrant population from each origin country at the national level.
（3）Export the aggregated datasets to the following Excel files:
   - `state_year_population.xlsx`
   - `state_year_origin_population.xlsx`
   - `nation_year_origin_population.xlsx`
（4）Run the R script `02_construct_panel_and_regression.R` to:
   - construct immigration-related variables,
   - import income and voting datasets,
   - construct dependent and control variables,
   - merge all datasets into a state-year panel,
   - run OLS and IV regressions.

## Main findings
(1) A higher immigration ratio leads to a higher voting share received by Democratic candidates in gubernatorial elections
(2) Due to the shift-share structure of the immigratio ratio (the key independent variable), the shift-share instrument can treat the causal problem in this research very well. The F-statistics (for the weak instrument diagnostics) of the shift-share instrument far exceed the threhold and are at least 25 times larger than those of the national immigration instrument.

## IPUMS restriction note
This project uses individual-level microdata from IPUMS USA. The original IPUMS microdata are not included in this repository because IPUMS Terms of Use restrict redistribution of the data. Researchers who wish to reproduce the analysis should create their own IPUMS extract using the sample years and variables described below.
IPUMS samples used:
- ACS / Census samples: 2000–2023
- Key variables: year (census year), statefip (state fip code), perwt (person weight), bpl (birthplace), and citizen (citizenship status).
