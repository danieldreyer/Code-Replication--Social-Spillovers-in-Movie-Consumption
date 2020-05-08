**************************************************************************
************************************* BEGIN TABLES: 
* LASSO and Instrument Robustness Checks 
* (AKA: BASECASEROBUST)
**************************************************************************

******************************
// clustered at weekend level
******************************
use main/dta/for_analyses.dta, clear
* set up case
local selected open_res_own_mat5_75_0
local selected_ownweather own_mat10_10 own_mat10_20 own_mat10_30 own_mat10_40 own_mat10_50 own_mat10_60 own_mat10_70 own_mat10_80 own_mat10_90 own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets

* controls
local controls1 ww* yy* h* dow_*

* get residual tickets controling for own weather for weeks 2+
gen `outcome'_r=.
forvalues i = 2/6{
	qui reg `outcome' `controls1' `selected_ownweather' if wk`i'==1
	qui predict tmp if wk`i'==1, r
	replace `outcome'_r = tmp if wk`i'==1
	qui egen `outcome'_wk`i'd_r = max(tmp), by(opening_sat_date dow)
	drop tmp
}
gen `outcome'_wkn1d_r = `outcome'_wk2d_r + `outcome'_wk3d_r + `outcome'_wk4d_r + `outcome'_wk5d_r + `outcome'_wk6d_r

***First IV by week and for all weeks not 1 on 1
* first stage
reg  `outcome'_wk1d_r `selected' if wk1==1, cluster(sat_date)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_cluswkend_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster(sat_date)
	outreg2 `outcome'_wk1d_r using tab/momentum_cluswkend_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk2==1, cluster(sat_date)
outreg2 `outcome'_wk1d_r using tab/momentum_cluswkend_`outcome'.xls, append

*** OLS by week and for all weeks not 1 on 1
* wknds: weeks 2-6 on 1
reg `outcome'_wk1d_r `outcome'_wk1d_r if wk1==1, cluster(sat_date)
outreg2 `outcome'_wk1d_r using tab/momentum_cluswkend_`outcome'_ols.xls, replace

forvalues i = 2/6{
	reg `outcome'_wk`i'd_r `outcome'_wk1d_r if wk`i'==1, cluster(sat_date)
	outreg2 `outcome'_wk1d_r using tab/momentum_cluswkend_`outcome'_ols.xls, append
}

* all weeks not 1 on 1
reg `outcome'_wkn1d_r `outcome'_wk1d_r if wk2==1, cluster(sat_date)
outreg2 `outcome'_wk1d_r using tab/momentum_cluswkend_`outcome'_ols.xls, append

******************************
// obs at weekend level
******************************
use main/dta/for_analyses.dta, clear
* set up case
local selected open_res_own_mat5_75_0
local selected_ownweather own_mat10_10 own_mat10_20 own_mat10_30 own_mat10_40 own_mat10_50 own_mat10_60 own_mat10_70 own_mat10_80 own_mat10_90 own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets

collapse (mean) ww* yy* open_res* own* wk* (sum) h* tickets*, by(opening_sat_date sat_date)

drop tickets_wk1_r

* controls
local controls1 ww* yy* h*

* get residual tickets controling for own weather for weeks 2+
gen `outcome'_r=.

qui reg `outcome' `controls1' if wk1==1
qui predict tmp if wk1==1, r
replace `outcome'_r = tmp if wk1==1
qui egen `outcome'_wk1_r = max(tmp), by(opening_sat_date)
drop tmp

forvalues i = 2/6{
	qui reg `outcome' `controls1' `selected_ownweather' if wk`i'==1
	qui predict tmp if wk`i'==1, r
	replace `outcome'_r = tmp if wk`i'==1
	qui egen `outcome'_wk`i'_r = max(tmp), by(opening_sat_date)
	drop tmp
}
gen `outcome'_wkn1_r = `outcome'_wk2_r + `outcome'_wk3_r + `outcome'_wk4_r + `outcome'_wk5_r + `outcome'_wk6_r

* run the first stage
reg `outcome'_wk1_r `selected' if wk2==1, cluster(sat_date)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentumwkend_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* wknds: weeks 2-6 on 1
forvalues i = 2/6{
	ivreg2 `outcome'_wk`i'_r (`outcome'_wk1_r = `selected') if wk`i'==1, cluster(sat_date)
	outreg2 `outcome'_wk1_r using tab/momentumwkend_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1_r (`outcome'_wk1_r = `selected') if wk2==1 , cluster(sat_date)
outreg2 `outcome'_wk1_r using tab/momentumwkend_`outcome'.xls, append

***Now OLS by week and for all weeks not 1 on 1
* wknds: weeks 2-6 on 1
reg `outcome'_wk2_r `outcome'_wk1_r if wk2==1 , cluster(sat_date)
outreg2 `outcome'_wk1_r using tab/momentumwkend_`outcome'_ols.xls, replace

forvalues i = 3/6{
	reg `outcome'_wk`i'_r `outcome'_wk1_r if wk`i'==1 , cluster(sat_date)
	outreg2 `outcome'_wk1_r using tab/momentumwkend_`outcome'_ols.xls, append
}

* all weeks not 1 on 1
reg `outcome'_wkn1_r `outcome'_wk1_r if wk2==1 , cluster(sat_date)
outreg2 `outcome'_wk1_r using tab/momentumwkend_`outcome'_ols.xls, append

******************************
// Main result controling for conemporaneous weather
******************************
* NOTE: have to use res_selected_ownweather NOT selected_ownweather since need to have residualized own weather
use main/dta/for_analyses.dta, clear
* set up case
local selected open_res_own_mat5_75_0
local res_selected_ownweather res_own_mat10_10 res_own_mat10_20 res_own_mat10_30 res_own_mat10_40 res_own_mat10_50 res_own_mat10_60 res_own_mat10_70 res_own_mat10_80 res_own_mat10_90 res_own_snow res_own_rain res_own_prec_0 res_own_prec_1 res_own_prec_2 res_own_prec_3 res_own_prec_4 res_own_prec_5
local outcome tickets
global clus date

* controls
local controls1 ww* yy* h* dow_*

* set up selected_own weather for each weekend
foreach var of varlist `res_selected_ownweather'{
	forvalues i = 2/6 {
		gen tmp = `var' if wk`i' == 1
		egen `var'_wk`i' = max(tmp), by(opening_sat_date dow)
		drop tmp
	}
}
local res_selected_ownweather_all res_own_mat10_10_wk* res_own_mat10_20_wk* res_own_mat10_30_wk* res_own_mat10_40_wk* res_own_mat10_50_wk* res_own_mat10_60_wk* res_own_mat10_70_wk* res_own_mat10_80_wk* res_own_mat10_90_wk* res_own_snow_wk* res_own_rain_wk* res_own_prec_0_wk* res_own_prec_1_wk* res_own_prec_2_wk* res_own_prec_3_wk* res_own_prec_4_wk* res_own_prec_5_wk*

* get residual tickets controling for own weather for weeks 2+
gen `outcome'_r=.
forvalues i = 2/6{
	qui reg `outcome' `controls1' if wk`i'==1
	qui predict tmp if wk`i'==1, r
	replace `outcome'_r = tmp if wk`i'==1
	*qui egen `outcome'_wk`i'_r = sum(tmp), by(opening_sat_date)
	qui egen `outcome'_wk`i'd_r = max(tmp), by(opening_sat_date dow)
	drop tmp
}
gen `outcome'_wkn1d_r = `outcome'_wk2d_r + `outcome'_wk3d_r + `outcome'_wk4d_r + `outcome'_wk5d_r + `outcome'_wk6d_r

***First IV by week and for all weeks not 1 on 1
* first stage
outreg2 `selected' using tab/momentum_contemp_`outcome'.xls, replace
forvalues i = 2/6{
	reg  `outcome'_wk1d_r `res_selected_ownweather' `selected' if wk`i'==1, cluster($clus)
	test `selected'
	local f_stat `r(F)'
	outreg2 `selected' using tab/momentum_contemp_`outcome'.xls, append ///
		addstat("F-stat", `f_stat')
}

reg  `outcome'_wk1d_r `res_selected_ownweather_all' `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_contemp_`outcome'.xls, append ///
	addstat("F-stat", `f_stat')
		
* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r `res_selected_ownweather' (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_contemp_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r `res_selected_ownweather_all' (`outcome'_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_contemp_`outcome'.xls, append
**************************************************************************
************************************* END TABLES: BASECASEROBUST
**************************************************************************
