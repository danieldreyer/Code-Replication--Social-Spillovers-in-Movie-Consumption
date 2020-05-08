**************************************************************************
************************************* BEGIN TABLES: 
* Network Externalities by Age Suitability 
* (AKA: BYMPAA)
**************************************************************************

********************************
// rated G & PG
********************************
use main/dta/for_analyses.dta, clear

* set up case
local selected open_res_own_prec_0_6
local selected_ownweather own_mat10_* own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets_ratedgpg

* controls
local controls1 ww* yy* h* dow_*

* get residual tickets controling for own weather for weeks 2+
gen `outcome'_r=.
forvalues i = 2/6{
	qui reg `outcome' `controls1' `selected_ownweather' if wk`i'==1 & `outcome'>0
	qui predict tmp if wk`i'==1 & `outcome'>0, r
	replace `outcome'_r = tmp if wk`i'==1
	qui egen `outcome'_wk`i'd_r = max(tmp), by(opening_sat_date dow)
	drop tmp
}
gen `outcome'_wkn1d_r = `outcome'_wk2d_r + `outcome'_wk3d_r + `outcome'_wk4d_r + `outcome'_wk5d_r + `outcome'_wk6d_r

***First IV by week and for all weeks not 1 on 1
* first stage
reg  `outcome'_wk1d_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 2/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'.xls, append

***Now OLS by week and for all weeks not 1 on 1
* wknds: weeks 2-6 on 1
reg `outcome'_wk2d_r `outcome'_wk1d_r if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_ols.xls, replace

forvalues i = 3/6{
	reg `outcome'_wk`i'd_r `outcome'_wk1d_r if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_ols.xls, append
}

* all weeks not 1 on 1
reg `outcome'_wkn1d_r `outcome'_wk1d_r if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_ols.xls, append
********************************


********************************
// rated adult
********************************
use main/dta/for_analyses.dta, clear

* set up case
local selected open_res_own_mat5_75_0
local selected_ownweather own_mat10_* own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets_adult

* controls
local controls1 ww* yy* h* dow_*

* get residual tickets controling for own weather for weeks 2+
gen `outcome'_r=.
forvalues i = 2/6{
	qui reg `outcome' `controls1' `selected_ownweather' if wk`i'==1 & `outcome'>0
	qui predict tmp if wk`i'==1 & `outcome'>0, r
	replace `outcome'_r = tmp if wk`i'==1
	qui egen `outcome'_wk`i'd_r = max(tmp), by(opening_sat_date dow)
	drop tmp
}
gen `outcome'_wkn1d_r = `outcome'_wk2d_r + `outcome'_wk3d_r + `outcome'_wk4d_r + `outcome'_wk5d_r + `outcome'_wk6d_r

***First IV by week and for all weeks not 1 on 1
* first stage
reg  `outcome'_wk1d_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 2/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'.xls, append

***Now OLS by week and for all weeks not 1 on 1
* wknds: weeks 2-6 on 1
reg `outcome'_wk2d_r `outcome'_wk1d_r if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_ols.xls, replace

forvalues i = 3/6{
	reg `outcome'_wk`i'd_r `outcome'_wk1d_r if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_ols.xls, append
}

* all weeks not 1 on 1
reg `outcome'_wkn1d_r `outcome'_wk1d_r if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_ols.xls, append

**************************************************************************
************************************* END TABLES: BYMPAA
**************************************************************************
