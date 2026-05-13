Research question: What is the effect of the immigration ratio on the voting share received by Democratic candidates in gubernatorial elections?

Data sources：
  (1) immigration-related variables: Integrated Public Use Microdata Series (IPUMS)
  (2) income-related variables: the Bureau of Economic Analysis (BEA)
  (3) the information about gubernatorial elections: Wikipedia

Variable definitions: 
   (1) demoper: the dependent variable; the vote share received by a Democratic candidate in a gubernatorial election
   (2) lag_immiciti_ratio: the key independent variable; the share of naturalized citizens in a state's citizen population, lagged by one year
   (3) lag_nationimmiratio: an instrumental variable; the share of naturalized citizens in the U.S. citizen population, lagged by one year
   (4) lag_ShiftShare: the shift-share instrumental variable; the difinition is shown in the paper
   (5) lag_incomegrowth: the per capita personal income growth rate, lagged by one year
   (6) lag_incomeratio: the ratio of state per capital personal income to national per capita personal income
   (7) morethant: a binary indicator equal to 1 if there were more than two gubernatorial candidates


The results of this project are developed into the paper (the PDF file "the paper")
I download the population microdata file (77 million data points) from the Integrated Public Use Microdata Series (IPUMS) for the years 2000 to 2023 and calculate 1. the the citizen population and naturalized immigrant population in each state, 2. immigrant population from each country in each state, 3. immigrant population from each country in USA. the calculation is performed on Stata, and the code is shown in the Stata script "Stata code".
I export the results from the Stata into Excel files "data 1", "data 2", and "data 3".
(As shown in the R script "R code") I import the Excel files "data 1", "data 2", and "data 3" into R, and generate new variables related to immigration. Then, I import the Excel files "income_data" and "voting_data" and contruct the dependent variable and the control variables; I merge the relevant datasets. Finally, I run the regressions.
