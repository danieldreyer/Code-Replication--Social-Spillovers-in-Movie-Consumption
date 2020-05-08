**************************************************************************
************************************* BEGIN TABLES: 
* Opening Weekend Viewership Shocks and Ratings 
* (AKA: EFFECTONRATINGS)
**************************************************************************

use main/dta/for_analyses, replace
local selected open_res_own_mat5_75_0
local selected_ownweather own_mat10_* own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5

egen tmp = sum(tickets_wk1_r), by(opening_sat_date sat_date)
drop tickets_wk1_r
ren tmp tickets_wk1_r

keep if wk1==1 & dow==5

* run the first stage
reg tickets_wk1_r `selected', cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_ratingprob.xls, replace ///
	addstat("F-stat", `f_stat')
	

foreach var of varlist vtop1000 rh1000 rl1000  {
local outcome `var'

ivreg2 `outcome'_wk1_r (tickets_wk1_r = `selected')
outreg2 tickets_wk1_r using tab/momentum_ratingprob.xls, append

reg `outcome'_wk1_r tickets_wk1_r
outreg2 tickets_wk1_r using tab/momentum_ratingprob.xls, append
}

**************************************************************************
************************************* END TABLES: EFFECTONRATINGS
**************************************************************************
