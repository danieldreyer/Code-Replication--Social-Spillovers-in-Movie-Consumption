# In diesem Skript werden die Tabellen 1,2 und 3 erstellt. 

# Die Datengrundlage bildet der Datensatz for_analyses.dta, der unter Data Archive
# im Bereich Supplemented Material zur Verfügung steht.

# Die verwendeten Instrumentalvariablen wurden mit der LASSO-Methode ausgewählt. Dazu wurde das Matlab-Skript
# RUN_LASSO_CLUSTERED auf den Datensatz opening_wkend_clus.csv angewendet. 

# Die gewonnenen Ergebnisse werden aus diesem R-Skript als Excel-Tabelle exportiert. 


# PACKAGES

# package to import dta files
install.packages("readstata13")
library(readstata13)

# package for function group_by
install.packages("dplyr")
library("dplyr")

# package for lm.cluster (clustered regression)
install.packages("miceadds")
library("miceadds")
install.packages("sandwich")
library("sandwich")

# package to export a data frame to xls
install.packages("writexl")
library("writexl")

# package for iv regression
install.packages("ivpack")
library("ivpack")

# IMPORT DATA
analyses <- read.dta13("C:/Users/user/Documents/alex/studium/master/2. semester/Seminar/code/from Stata/for_analyses.dta")
for_analyses <- analyses



########################## TABLE 1 ###########################################

# create table only with wk1 data
analyses_wk1 <- analyses[grep(1,analyses$wk1),]

# Choose 1 (75-80° increment), clustered by date
reg_choose1 <- lm.cluster(data = analyses_wk1, formula = analyses_wk1$tickets_wk1d_r ~ analyses_wk1$open_res_own_mat5_75_0, cluster = analyses_wk1$date)
# save coefficient
choose1_coeff <- as.numeric(coef(reg_choose1)[2])
# save std error
choose1_stderror <- as.numeric(summary(reg_choose1)[4])
# F-statistic
# number of parameters
parameters <- 2
# number of observations
observations <- nrow(analyses_wk1)
# R^2
r2 <- 0.01808
# calculate F-statistic
choose1_f_stat <- (r2/(parameters-1))/((1-r2)/(observations-parameters))
# delete regression
rm(reg_choose1)

# Choose 2 ( 75-80° and 50-55° increment)
reg_choose2 <- lm.cluster(data = analyses_wk1, formula = analyses_wk1$tickets_wk1d_r ~ analyses_wk1$open_res_own_mat5_75_0 + analyses_wk1$open_res_own_mat5_50_6, cluster = analyses_wk1$date)
# save coefficients
choose2_coef <- as.numeric(coef(reg_choose2)[2:3])
# save std errors
choose2_stderror <- as.numeric(summary(reg_choose2)[5:6])
# F-statistic
# number of parameters
parameters <- 3
# number of observations
observations <- nrow(analyses_wk1)
# R^2
r2 <- 0.03247
# calculate F-statistic
choose2_f_stat <- (r2/(parameters-1))/((1-r2)/(observations-parameters))
# delete regression
rm(reg_choose2)

# 10° temperature increment, choose 1 (70-80° increment)
reg_deg_10<- lm.cluster(data = analyses_wk1, formula = analyses_wk1$tickets_wk1d_r ~ analyses_wk1$open_res_own_mat10_70_6, cluster = analyses_wk1$date)
# save coefficient
deg_10_coef <- as.numeric(coef(reg_deg_10)[2])
# save std error
deg_10_stderror <- as.numeric(summary(reg_deg_10)[4])
# F-statistic
# number of parameters
parameters <- 2
# number of observations
observations <- nrow(analyses_wk1)
# R^2
r2 <- 0.00816
# calculate F-statistic
deg_10_f_stat <- (r2/(parameters-1))/((1-r2)/(observations-parameters))
# delete regression
rm(reg_deg_10)

# Hand-Selected Instruments
# mat_la_cens
# 10° temperature increment, choose 1 (70-80° increment)
reg_hand <- lm.cluster(data = analyses_wk1, formula = analyses_wk1$tickets_wk1d_r ~ analyses_wk1$open_res_own_mat_la_cens_6, cluster = analyses_wk1$date)
# save coefficient
hand_coef <- as.numeric(coef(reg_hand)[2])
# save std error
hand_stderror <- as.numeric(summary(reg_hand)[4])
# F-statistic
# number of parameters
parameters <- 2
# number of observations
observations <- nrow(analyses_wk1)
# R^2
r2 <- 0.02189
# calculate F-statistic
hand_f_stat <- (r2/(parameters-1))/((1-r2)/(observations-parameters))
# delete regression
rm(reg_hand)

# All instruments provided to LASSO
all_instruments <- as.matrix(analyses_wk1[c(474,475,477,478,480,481,483,484,486,487,489,490,492,493,495,496,498,499,501,502,504,505,507,508,510,511,513,514,516,517,519,520,522,523,525,526,528,529,531,532,534,535,537,538,540,541,543,544,546,547,549,550)])
# reg all innstruments
reg_all <- lm.cluster(data = analyses_wk1, formula = analyses_wk1$tickets_wk1d_r ~ all_instruments, cluster = analyses_wk1$date)
# F-statistic
# number of parameters
parameters <- ncol(all_instruments)+1
# number of observations
observations <- nrow(analyses_wk1)
# R^2
r2 <- 0.09994
# calculate F-statistic
all_f_stat <- (r2/(parameters-1))/((1-r2)/(observations-parameters))
# delete regression
rm(reg_all)

# put together the important results and Export to Excel
table1 <- c(choose1_coeff,choose1_stderror,choose1_f_stat)
choose2_1 <- c(choose2_coef[1],choose2_stderror[1],choose2_f_stat)
table1 <- rbind(table1,choose2_1)
choose2_2 <- c(choose2_coef[2],choose2_stderror[2],NA)
table1 <- rbind(table1,choose2_2)
deg_10 <- c(deg_10_coef,deg_10_stderror,deg_10_f_stat)
table1 <- rbind(table1,deg_10)
hand <- c(hand_coef,hand_stderror,hand_f_stat)
table1 <- rbind(table1,hand)
all <- c(NA,NA,all_f_stat)
table1 <- rbind(table1,all)
# export
table1 <- as.data.frame(table1)
write_xlsx(table1,"C:/Users/user/Documents/alex/studium/master/2. semester/Seminar/Export Tabellen/Tabelle1.xlsx")

rm(analyses_wk1,choose2_1,choose1_coeff,choose1_f_stat,choose1_stderror,choose2_2,choose2_coef,choose2_f_stat,choose2_stderror,deg_10,deg_10_coef,deg_10_f_stat,deg_10_stderror,hand,hand_coef,hand_f_stat,hand_stderror,all,all_f_stat)


########################## TABLE 2 ###########################################

# get residual tickets controlling for own weather for weeks 2+
# for each subset with wki==1 (i from 2 to 6) 
# we regress tickets on holidays, year, week, dow and own weather and caltulate the residuals

# week 2
# subset of analyses where wk2==1
analyses.limited <- subset(analyses,wk2==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg1 <- lm(data=analyses.limited, formula=analyses.limited$tickets ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg1)
rm(reg1)
# create vector of length nrow(analyses), NA if wk2!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_wk2d_r" with the residuals to analyses
analyses["tickets_wk2d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_wk2d_r=max(tickets_wk2d_r,na.rm = TRUE))

# week 3
# subset of analyses where wk3==1
analyses.limited <- subset(for_analyses,analyses$wk3==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg2 <- lm(data=analyses.limited, formula=analyses.limited$tickets ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg2)
rm(reg2)
# create vector of length nrow(analyses), zero if wk3!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_wk3d_r" with the residuals to analyses
analyses["tickets_wk3d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_wk3d_r=max(tickets_wk3d_r,na.rm = TRUE))

# week 4
# subset of analyses where wk4==1
analyses.limited <- subset(for_analyses,wk4==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg3 <- lm(data=analyses.limited, formula=analyses.limited$tickets ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg3)
rm(reg3)
# create vector of length nrow(analyses), zero if wk4!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_wk4d_r" with the residuals to analyses
analyses["tickets_wk4d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_wk4d_r=max(tickets_wk4d_r,na.rm = TRUE))

# week 5
# subset of analyses where wk5==1
analyses.limited <- subset(for_analyses,wk5==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg4 <- lm(data=analyses.limited, formula=analyses.limited$tickets ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg4)
rm(reg4)
# create vector of length nrow(analyses), zero if wk5!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_wk5d_r" with the residuals to analyses
analyses["tickets_wk5d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_wk5d_r=max(tickets_wk5d_r,na.rm = TRUE))

# week 6
# subset of analyses where wk6==1
analyses.limited <- subset(for_analyses,wk6==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg5 <- lm(data=analyses.limited, formula=analyses.limited$tickets ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg5)
rm(reg5)
# create vector of length nrow(analyses), zero if wk6!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_wk6d_r" with the residuals to analyses
analyses["tickets_wk6d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_wk6d_r=max(tickets_wk6d_r,na.rm = TRUE))

# calculate variable tickets_wkn1d_r as sum of tickets>_wkid_r (i from 2 to 6)
analyses <- mutate(analyses,tickets_wkn1d_r=tickets_wk2d_r+tickets_wk3d_r+tickets_wk4d_r+tickets_wk5d_r+tickets_wk6d_r)


# IV REGRESSION

# for i from 2 to 6 we want to regress tickets_wkid_r on tickets_wk1d_r
# LASSO chosen instrument
# we instrument for tickets_wk1d_r with the 75-80° temperature increment

# week 2
analyses.limited <- subset(analyses,wk2==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk2d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
lasso_coef <- coefficients(ivreg)[2] # vector with coefficients (first row of Table 2)
lasso_stderror <- cluster.robust.se(ivreg,analyses.limited$date)[4]

# week 3
analyses.limited <- subset(analyses,wk3==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk3d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
lasso_coef <- c(lasso_coef,coefficients(ivreg)[2]) # vector with coefficients (first row of Table 2)
lasso_stderror <- c(lasso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 4
analyses.limited <- subset(analyses,wk4==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk4d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
lasso_coef <- c(lasso_coef,coefficients(ivreg)[2]) # vector with coefficients (first row of Table 2)
lasso_stderror <- c(lasso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 5
analyses.limited <- subset(analyses,wk5==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk5d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
lasso_coef <- c(lasso_coef,coefficients(ivreg)[2]) # vector with coefficients (first row of Table 2)
lasso_stderror <- c(lasso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 6
analyses.limited <- subset(analyses,wk6==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk6d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
lasso_coef <- c(lasso_coef,coefficients(ivreg)[2]) # vector with coefficients (first row of Table 2)
lasso_stderror <- c(lasso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 2-6 
analyses.limited <- subset(analyses,wk1==1)
# regress tickets_wkn1d_r on tickets_wk1d_r
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wkn1d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
lasso_coef <- c(lasso_coef,coefficients(ivreg)[2]) # vector with coefficients (first row of Table 2)
lasso_stderror <- c(lasso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])


# Hand-selected instrument (temp-75)^2*(abs(temp-75°)<=20)
# we instrument for tickets_wk1d_r with open_res_own_mat_la_cens_6

# week 2
analyses.limited <- subset(analyses,wk2==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk2d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat_la_cens_6, na.action = NULL)
matla_coef <- coefficients(ivreg)[2] # vector with coefficients (second row of Table 2)
matla_stderror <- cluster.robust.se(ivreg,analyses.limited$date)[4]

# week 3
analyses.limited <- subset(analyses,wk3==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk3d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat_la_cens_6, na.action = NULL)
matla_coef <- c(matla_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
matla_stderror <- c(matla_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 4
analyses.limited <- subset(analyses,wk4==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk4d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat_la_cens_6, na.action = NULL)
matla_coef <- c(matla_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
matla_stderror <- c(matla_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 5
analyses.limited <- subset(analyses,wk5==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk5d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat_la_cens_6, na.action = NULL)
matla_coef <- c(matla_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
matla_stderror <- c(matla_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 6
analyses.limited <- subset(analyses,wk6==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk6d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat_la_cens_6, na.action = NULL)
matla_coef <- c(matla_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
matla_stderror <- c(matla_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 2-6 
analyses.limited <- subset(analyses,wk1==1)
# regress tickets_wkn1d_r on tickets_wk1d_r
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wkn1d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ analyses.limited$open_res_own_mat_la_cens_6, na.action = NULL)
matla_coef <- c(matla_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
matla_stderror <- c(matla_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])


# All instruments provided to LASSO
# we instrument for tickets_wk1d_r with all instruments provided to LASSO

# week 2
analyses.limited <- subset(analyses,wk2==1)
# all instruments provided to LASSO
all_instruments <- as.matrix(analyses.limited[c(474,475,477,478,480,481,483,484,486,487,489,490,492,493,495,496,498,499,501,502,504,505,507,508,510,511,513,514,516,517,519,520,522,523,525,526,528,529,531,532,534,535,537,538,540,541,543,544,546,547,549,550)])
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk2d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ all_instruments, na.action = NULL)
all_coef <- coefficients(ivreg)[2] # vector with coefficients (second row of Table 2)
all_stderror <- cluster.robust.se(ivreg,analyses.limited$date)[4]

# week 3
analyses.limited <- subset(analyses,wk3==1)
# all instruments provided to LASSO
all_instruments <- as.matrix(analyses.limited[c(474,475,477,478,480,481,483,484,486,487,489,490,492,493,495,496,498,499,501,502,504,505,507,508,510,511,513,514,516,517,519,520,522,523,525,526,528,529,531,532,534,535,537,538,540,541,543,544,546,547,549,550)])
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk3d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ all_instruments, na.action = NULL)
all_coef <- c(all_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
all_stderror <- c(all_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 4
analyses.limited <- subset(analyses,wk4==1)
# all instruments provided to LASSO
all_instruments <- as.matrix(analyses.limited[c(474,475,477,478,480,481,483,484,486,487,489,490,492,493,495,496,498,499,501,502,504,505,507,508,510,511,513,514,516,517,519,520,522,523,525,526,528,529,531,532,534,535,537,538,540,541,543,544,546,547,549,550)])
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk4d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ all_instruments, na.action = NULL)
all_coef <- c(all_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
all_stderror <- c(all_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 5
analyses.limited <- subset(analyses,wk5==1)
# all instruments provided to LASSO
all_instruments <- as.matrix(analyses.limited[c(474,475,477,478,480,481,483,484,486,487,489,490,492,493,495,496,498,499,501,502,504,505,507,508,510,511,513,514,516,517,519,520,522,523,525,526,528,529,531,532,534,535,537,538,540,541,543,544,546,547,549,550)])
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk5d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ all_instruments, na.action = NULL)
all_coef <- c(all_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
all_stderror <- c(all_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 6
analyses.limited <- subset(analyses,wk6==1)
# all instruments provided to LASSO
all_instruments <- as.matrix(analyses.limited[c(474,475,477,478,480,481,483,484,486,487,489,490,492,493,495,496,498,499,501,502,504,505,507,508,510,511,513,514,516,517,519,520,522,523,525,526,528,529,531,532,534,535,537,538,540,541,543,544,546,547,549,550)])
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk6d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ all_instruments, na.action = NULL)
all_coef <- c(all_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
all_stderror <- c(all_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 2-6 
analyses.limited <- subset(analyses,wk1==1)
# all instruments provided to LASSO
all_instruments <- as.matrix(analyses.limited[c(474,475,477,478,480,481,483,484,486,487,489,490,492,493,495,496,498,499,501,502,504,505,507,508,510,511,513,514,516,517,519,520,522,523,525,526,528,529,531,532,534,535,537,538,540,541,543,544,546,547,549,550)])
# regress tickets_wkn1d_r on tickets_wk1d_r
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wkn1d_r ~ analyses.limited$tickets_wk1d_r, instruments= ~ all_instruments, na.action = NULL)
all_coef <- c(all_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 2)
all_stderror <- c(all_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])


# OLS

# week 2
analyses.limited <- subset(analyses,wk2==1)
# OLS
reg <- lm(data = analyses.limited, formula = analyses.limited$tickets_wk2d_r ~ analyses.limited$tickets_wk1d_r, na.action = NULL)
ols_coef <- coefficients(reg)[2] # vector with coefficients (fourth row of Table 2)
ols_stderror <- cluster.robust.se(reg,analyses.limited$date)[4]
ols_r2 <- summary(reg)$r.squared

# week 3
analyses.limited <- subset(analyses,wk3==1)
# OLS
reg <- lm(data = analyses.limited, formula = analyses.limited$tickets_wk3d_r ~ analyses.limited$tickets_wk1d_r, na.action = NULL)
ols_coef <- c(ols_coef,coefficients(reg)[2]) # vector with coefficients (fourth row of Table 2)
ols_stderror <- c(ols_stderror,cluster.robust.se(reg,analyses.limited$date)[4])
ols_r2 <- c(ols_r2,summary(reg)$r.squared)

# week 4
analyses.limited <- subset(analyses,wk4==1)
# OLS
reg <- lm(data = analyses.limited, formula = analyses.limited$tickets_wk4d_r ~ analyses.limited$tickets_wk1d_r, na.action = NULL)
ols_coef <- c(ols_coef,coefficients(reg)[2]) # vector with coefficients (fourth row of Table 2)
ols_stderror <- c(ols_stderror,cluster.robust.se(reg,analyses.limited$date)[4])
ols_r2 <- c(ols_r2,summary(reg)$r.squared)

# week 5
analyses.limited <- subset(analyses,wk5==1)
# OLS
reg <- lm(data = analyses.limited, formula = analyses.limited$tickets_wk5d_r ~ analyses.limited$tickets_wk1d_r, na.action = NULL)
ols_coef <- c(ols_coef,coefficients(reg)[2]) # vector with coefficients (fourth row of Table 2)
ols_stderror <- c(ols_stderror,cluster.robust.se(reg,analyses.limited$date)[4])
ols_r2 <- c(ols_r2,summary(reg)$r.squared)

# week 6
analyses.limited <- subset(analyses,wk6==1)
# OLS
reg <- lm(data = analyses.limited, formula = analyses.limited$tickets_wk6d_r ~ analyses.limited$tickets_wk1d_r, na.action = NULL)
ols_coef <- c(ols_coef,coefficients(reg)[2]) # vector with coefficients (fourth row of Table 2)
ols_stderror <- c(ols_stderror,cluster.robust.se(reg,analyses.limited$date)[4])
ols_r2 <- c(ols_r2,summary(reg)$r.squared)

# week 2-6 
analyses.limited <- subset(analyses,wk1==1)
# regress tickets_wkn1d_r on tickets_wk1d_r
reg <- lm(data = analyses.limited, formula = analyses.limited$tickets_wkn1d_r ~ analyses.limited$tickets_wk1d_r, na.action = NULL)
ols_coef <- c(ols_coef,coefficients(reg)[2]) # vector with coefficients (fourth row of Table 2)
ols_stderror <- c(ols_stderror,cluster.robust.se(reg,analyses.limited$date)[4])
ols_r2 <- c(ols_r2,summary(reg)$r.squared)


# put together the results and export to Excel
table2 <- rbind(lasso_coef,lasso_stderror,matla_coef,matla_stderror,all_coef,all_stderror,ols_coef,ols_stderror,ols_r2)
table2 <- as.data.frame(table2)
write_xlsx(table2,"C:/Users/user/Documents/alex/studium/master/2. semester/Seminar/Export Tabellen/Tabelle2.xlsx")

rm(reg,ivreg,matla_coef,matla_stderror,all_coef,all_stderror,ols_coef,ols_stderror,ols_r2,analyses.limited,all_instruments)


########################## TABLE 3 ###########################################

# BASE CASE CONTROLLING FOR OPENING THEATERS
# first stage

# create table only with wk1 data
analyses.limited <- subset(analyses,wk1==1)
# regress tickets_wk1d_r on theaterso and open_res_own_mat5_75_0
reg_control_theaterso <- lm.cluster(data = analyses.limited, formula = analyses.limited$tickets_wk1d_r ~ analyses.limited$theaterso + analyses.limited$open_res_own_mat5_75_0, cluster = analyses.limited$date)
# save coefficient
control_theaterso_coef <- as.numeric(coef(reg_choose1)[3])
# save std error
control_theaterso_stderror <- as.numeric(summary(reg_choose1)[6])
# F-statistic
# number of parameters
parameters <- 3
# number of observations
observations <- nrow(analyses.limited)
# R^2
r2 <- 0.10165
# calculate F-statistic
control_theaterso_f_stat <- (r2/(parameters-1))/((1-r2)/(observations-parameters))
# delete regression
rm(reg_control_theaterso)

# second stage
# we regress tickets_wkid_r on tickets_wk1d_r instrumented with the 75-80° increment and controlled for theaterso

# week 1
# coefficient will be 1 and std error will be 0
control_theaterso_coef <- 1
control_theaterso_stderror <- 0

# week 2
analyses.limited <- subset(analyses,wk2==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk2d_r ~ analyses.limited$tickets_wk1d_r + analyses.limited$theaterso | analyses.limited$theaterso + analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
control_theaterso_coef <- c(control_theaterso_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 3)
control_theaterso_stderror <- c(control_theaterso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[5])

# week 3
analyses.limited <- subset(analyses,wk3==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk3d_r ~ analyses.limited$tickets_wk1d_r + analyses.limited$theaterso | analyses.limited$theaterso + analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
control_theaterso_coef <- c(control_theaterso_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 3)
control_theaterso_stderror <- c(control_theaterso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 4
analyses.limited <- subset(analyses,wk4==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk4d_r ~ analyses.limited$tickets_wk1d_r + analyses.limited$theaterso | analyses.limited$theaterso + analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
control_theaterso_coef <- c(control_theaterso_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 3)
control_theaterso_stderror <- c(control_theaterso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 5
analyses.limited <- subset(analyses,wk5==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk5d_r ~ analyses.limited$tickets_wk1d_r + analyses.limited$theaterso | analyses.limited$theaterso + analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
control_theaterso_coef <- c(control_theaterso_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 3)
control_theaterso_stderror <- c(control_theaterso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 6
analyses.limited <- subset(analyses,wk6==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wk6d_r ~ analyses.limited$tickets_wk1d_r + analyses.limited$theaterso | analyses.limited$theaterso + analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
control_theaterso_coef <- c(control_theaterso_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 3)
control_theaterso_stderror <- c(control_theaterso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 2-6 
analyses.limited <- subset(analyses,wk1==1)
# regress tickets_wkn1d_r on tickets_wk1d_r
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_wkn1d_r ~ analyses.limited$tickets_wk1d_r + analyses.limited$theaterso | analyses.limited$theaterso + analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
control_theaterso_coef <- c(control_theaterso_coef,coefficients(ivreg)[2]) # vector with coefficients (second row of Table 3)
control_theaterso_stderror <- c(control_theaterso_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])


# BASE CASE PER OPENING THEATERS

# get residual tickets per opening theaters controlling for own weather for weeks 2+
# for each subset with wki==1 (i from 2 to 6) 
# we regress tickets_pot on holidays, year, week, dow and own weather and caltulate the residuals

# week 2
# subset of analyses where wk2==1
analyses.limited <- subset(for_analyses,wk2==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg1 <- lm(data=analyses.limited, formula=analyses.limited$tickets_pot ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg1)
rm(reg1)
# create vector of length nrow(analyses), NA if wk2!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_pot_wk2d_r" with the residuals to analyses
analyses["tickets_pot_wk2d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_pot_wk2d_r=max(tickets_pot_wk2d_r,na.rm = TRUE))

# week 3
# subset of analyses where wk3==1
analyses.limited <- subset(for_analyses,analyses$wk3==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg2 <- lm(data=analyses.limited, formula=analyses.limited$tickets_pot ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg2)
rm(reg2)
# create vector of length nrow(analyses), NA if wk3!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_pot_wk3d_r" with the residuals to analyses
analyses["tickets_pot_wk3d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_pot_wk3d_r=max(tickets_pot_wk3d_r,na.rm = TRUE))

# week 4
# subset of analyses where wk4==1
analyses.limited <- subset(for_analyses,wk4==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg3 <- lm(data=analyses.limited, formula=analyses.limited$tickets_pot ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg3)
rm(reg3)
# create vector of length nrow(analyses), NA if wk4!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_pot_wk4d_r" with the residuals to analyses
analyses["tickets_pot_wk4d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_pot_wk4d_r=max(tickets_pot_wk4d_r,na.rm = TRUE))

# week 5
# subset of analyses where wk5==1
analyses.limited <- subset(for_analyses,wk5==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg4 <- lm(data=analyses.limited, formula=analyses.limited$tickets_pot ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg4)
rm(reg4)
# create vector of length nrow(analyses), NA if wk5!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_pot_wk5d_r" with the residuals to analyses
analyses["tickets_pot_wk5d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_pot_wk5d_r=max(tickets_pot_wk5d_r,na.rm = TRUE))

# week 6
# subset of analyses where wk6==1
analyses.limited <- subset(for_analyses,wk6==1)
# create matrix with the variables holidays, year, week, dow and own weather
variables <- as.matrix(analyses.limited[c(72:130,188:253,254:262,149,150,169:174)])
# regression
reg5 <- lm(data=analyses.limited, formula=analyses.limited$tickets_pot ~ variables, na.action = na.exclude)
# residuals
res <- residuals(reg5)
rm(reg5)
# create vector of length nrow(analyses), NA if wk6!=1
residuals_all <- rep(NA,nrow(analyses))
# fill the vector with values from res
for (i in c(1:length(res))){
  residuals_all[as.numeric(names(res)[i])] <- res[i]
}
# add column "tickets_pot_wk6d_r" with the residuals to analyses
analyses["tickets_pot_wk6d_r"] <- residuals_all
# calculate the max, grouped by opening_sat_date and dow
analyses <- analyses %>% group_by(opening_sat_date, dow) %>% mutate(tickets_pot_wk6d_r=max(tickets_pot_wk6d_r,na.rm = TRUE))

# calculate variable tickets_pot_wkn1d_r as sum of tickets_pot_wkid_r (i from 2 to 6)
analyses <- mutate(analyses,tickets_pot_wkn1d_r=tickets_pot_wk2d_r+tickets_pot_wk3d_r+tickets_pot_wk4d_r+tickets_pot_wk5d_r+tickets_pot_wk6d_r)

rm(variables,res,residuals_all)

# IV
# first stage

# create table only with wk1 data
analyses.limited <- subset(analyses,wk1==1)
# regress tickets_pot_wk1d_r (tickets per opening theater) on open_res_own_mat5_75_0
reg_tickets_pot <- lm.cluster(data = analyses.limited, formula = analyses.limited$tickets_pot_wk1d_r ~ analyses.limited$open_res_own_mat5_75_0, cluster = analyses.limited$date)
# save coefficient
tickets_pot_coef <- as.numeric(coef(reg_tickets_pot)[2])
# save std error
tickets_pot_stderror <- as.numeric(summary(reg_tichets_pot)[4])
# F-statistic
# number of parameters
parameters <- 2
# number of observations
observations <- nrow(analyses.limited)
# R^2
r2 <- 0.00526
# calculate F-statistic
control_theaterso_f_stat <- (r2/(parameters-1))/((1-r2)/(observations-parameters))
# delete regression
rm(reg_tickets_pot,parameters,observations,r2)


# second stage
# we regress tickets_pot_wkid_r on tickets_wk1d_r instrumented with the 75-80° increment

# week 1
analyses.limited <- subset(analyses,wk1==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_pot_wk1d_r ~ analyses.limited$tickets_wk1d_r | analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
tickets_pot_coef <- coefficients(ivreg)[2] # vector with coefficients (third row of Table 3)
tickets_pot_stderror <- cluster.robust.se(ivreg,analyses.limited$date)[4]

# week 2
analyses.limited <- subset(analyses,wk2==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_pot_wk2d_r ~ analyses.limited$tickets_wk1d_r | analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
tickets_pot_coef <- c(tickets_pot_coef,coefficients(ivreg)[2]) # vector with coefficients (third row of Table 3)
tickets_pot_stderror <- c(tickets_pot_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 3
analyses.limited <- subset(analyses,wk3==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_pot_wk3d_r ~ analyses.limited$tickets_wk1d_r | analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
tickets_pot_coef <- c(tickets_pot_coef,coefficients(ivreg)[2]) # vector with coefficients (third row of Table 3)
tickets_pot_stderror <- c(tickets_pot_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 4
analyses.limited <- subset(analyses,wk4==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_pot_wk4d_r ~ analyses.limited$tickets_wk1d_r | analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
tickets_pot_coef <- c(tickets_pot_coef,coefficients(ivreg)[2]) # vector with coefficients (third row of Table 3)
tickets_pot_stderror <- c(tickets_pot_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 5
analyses.limited <- subset(analyses,wk5==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_pot_wk5d_r ~ analyses.limited$tickets_wk1d_r | analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
tickets_pot_coef <- c(tickets_pot_coef,coefficients(ivreg)[2]) # vector with coefficients (third row of Table 3)
tickets_pot_stderror <- c(tickets_pot_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 6
analyses.limited <- subset(analyses,wk6==1)
# iv regression
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_pot_wk6d_r ~ analyses.limited$tickets_wk1d_r | analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
tickets_pot_coef <- c(tickets_pot_coef,coefficients(ivreg)[2]) # vector with coefficients (third row of Table 3)
tickets_pot_stderror <- c(tickets_pot_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])

# week 2-6 
analyses.limited <- subset(analyses,wk1==1)
# regress tickets_wkn1d_r on tickets_wk1d_r
ivreg <- ivreg(data = analyses.limited, formula = analyses.limited$tickets_pot_wkn1d_r ~ analyses.limited$tickets_wk1d_r | analyses.limited$open_res_own_mat5_75_0, na.action = NULL)
tickets_pot_coef <- c(tickets_pot_coef,coefficients(ivreg)[2]) # vector with coefficients (third row of Table 3)
tickets_pot_stderror <- c(tickets_pot_stderror,cluster.robust.se(ivreg,analyses.limited$date)[4])


# calculate standardized values for tickets per opening theaters
std_tickets_pot_coef <- (1/tickets_pot_coef[1])*tickets_pot_coef
std_tickets_pot_stderror <- (1/tickets_pot_coef[1])*tickets_pot_stderror


# put results together and export to Excel
lasso_coef <- c(1,lasso_coef)
lasso_stderror <- c(0,lasso_stderror)
table3 <- rbind(lasso_coef,lasso_stderror,control_theaterso_coef,control_theaterso_stderror,tickets_pot_coef,tickets_pot_stderror,std_tickets_pot_coef,std_tickets_pot_stderror)
table3 <- as.data.frame(table3)
write_xlsx(table3,"C:/Users/user/Documents/alex/studium/master/2. semester/Seminar/Export Tabellen/Tabelle3.xlsx")

rm(analyses.limited,ivreg,lasso_coef,lasso_stderror,control_theaterso_coef,control_theaterso_stderror,tickets_pot_coef,tickets_pot_stderror,std_tickets_pot_coef,std_tickets_pot_stderror)
