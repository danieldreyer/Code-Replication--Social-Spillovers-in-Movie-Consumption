**************************************************************************
************************************* BEGIN TABLES: 
* LASSO-Chosen and Hand-Selected First Stages,
* Momentum from Viewership Shocks,
* LASSO and Instrument Robustness Checks 
* (aka: LASSOFIRST, BASECASE, LASSOROBUST)
**************************************************************************

********************************
********************************
// BASE CASE: LASSO-CHOSEN  
********************************
use main/dta/for_analyses.dta, replace

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
reg  `outcome'_wk1d_r `selected' if wk1==1, cluster(date)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk1==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'.xls, append

* compute confidence interval on OLS relative to IV
gmm (eq1: tickets_wkn1d_r - {a0} - tickets_wk1d_r*{beta}) ///
	(eq2: tickets_wkn1d_r - {a1} - tickets_wk1d_r*{delta}) ///
	if wk1==1, ///
	instruments(eq1: open_res_own_mat5_75_0) ///
	instruments(eq2: tickets_wk1d_r) onestep vce(robust) ///
	winitial(unadjusted, indep)
lincom [delta]_cons - [beta]_cons

*** OLS
* wknds: weeks 2-6 on 1
reg `outcome'_wk1d_r `outcome'_wk1d_r if wk1==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_ols.xls, replace

forvalues i = 2/6{
	reg `outcome'_wk`i'd_r `outcome'_wk1d_r if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_ols.xls, append
}

* all weeks not 1 on 1
reg `outcome'_wkn1d_r `outcome'_wk1d_r if wk1==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_ols.xls, append


*************************************
// using mat_la_cens = (mat-75)^2 * ( |mat-75|<=20 )
*************************************
use main/dta/for_analyses.dta, replace
* set up case
local selected open_res_own_mat_la_cens_6
local selected_ownweather own_mat10_10 own_mat10_20 own_mat10_30 own_mat10_40 own_mat10_50 own_mat10_60 own_mat10_70 own_mat10_80 own_mat10_90 own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets
global clus date

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
reg  `outcome'_wk1d_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_la_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

	
* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_la_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_la_`outcome'.xls, append
	

*************************************
// using all instruments fed into LASSO
*************************************
use main/dta/for_analyses.dta, replace
* set up case
local selected ///
open_res_own_mat5_10_6 open_res_own_mat5_15_6 open_res_own_mat5_20_6 open_res_own_mat5_25_6 open_res_own_mat5_30_6 ///
open_res_own_mat5_35_6 open_res_own_mat5_40_6 open_res_own_mat5_45_6 open_res_own_mat5_50_6 open_res_own_mat5_55_6 open_res_own_mat5_60_6 ///
open_res_own_mat5_65_6 open_res_own_mat5_70_6 open_res_own_mat5_75_6 open_res_own_mat5_80_6 open_res_own_mat5_85_6 open_res_own_mat5_90_6 ///
open_res_own_mat5_95_6 ///
open_res_own_mat5_10_0 open_res_own_mat5_15_0 open_res_own_mat5_20_0 open_res_own_mat5_25_0 open_res_own_mat5_30_0 ///
open_res_own_mat5_35_0 open_res_own_mat5_40_0 open_res_own_mat5_45_0 open_res_own_mat5_50_0 open_res_own_mat5_55_0 open_res_own_mat5_60_0 ///
open_res_own_mat5_65_0 open_res_own_mat5_70_0 open_res_own_mat5_75_0 open_res_own_mat5_80_0 open_res_own_mat5_85_0 open_res_own_mat5_90_0 ///
open_res_own_mat5_95_0 ///
open_res_own_rain_6 open_res_own_rain_0 ///
open_res_own_snow_6 open_res_own_snow_0 ///
open_res_own_prec_0_6 open_res_own_prec_1_6 open_res_own_prec_2_6 open_res_own_prec_3_6 open_res_own_prec_4_6 open_res_own_prec_5_6 ///
open_res_own_prec_0_0 open_res_own_prec_1_0 open_res_own_prec_2_0 open_res_own_prec_3_0 open_res_own_prec_4_0 open_res_own_prec_5_0 ///

local selected_ownweather own_mat10_10 own_mat10_20 own_mat10_30 own_mat10_40 own_mat10_50 own_mat10_60 own_mat10_70 own_mat10_80 own_mat10_90 own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets
global clus date

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
reg  `outcome'_wk1d_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_allinst_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_allinst_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_allinst_`outcome'.xls, append

	
** magntiude: all weeks residualized and non residualized on opening weekend weather
gen `outcome'_allwks_r = `outcome'_wk1d_r +  `outcome'_wkn1d_r
reg `outcome'_allwks_r	`selected'  if wk1==1,r

egen `outcome'_allwks = sum(`outcome'), by(opening_sat_date dow)
reg `outcome'_allwks	`selected'  if wk1==1,r

* first weekend only
reg `outcome' `selected'  if wk1==1,r
reg tickets_wk1d_r `selected'  if wk1==1,r

* and our lasso selected
reg tickets_allwks_r open_res_own_mat5_75_0 if wk1==1,r
reg tickets_allwks open_res_own_mat5_75_0 if wk1==1,r

reg tickets open_res_own_mat5_75_0 if wk1==1,r
reg tickets_wk1d_r open_res_own_mat5_75_0 if wk1==1,r
reg tickets_wk3d_r  tickets_wk2d_r if wk1==1,r
reg tickets_wk4d_r  tickets_wk3d_r if wk1==1,r
reg tickets_wk5d_r  tickets_wk4d_r if wk1==1,r
reg tickets_wk6d_r  tickets_wk5d_r if wk1==1,r
********************************

*************************************
// Choose 2 instruments
*************************************
use main/dta/for_analyses.dta, replace

local selected open_res_own_mat5_50_6 open_res_own_mat5_75_0 
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
	*qui egen `outcome'_wk`i'_r = sum(tmp), by(opening_sat_date)
	qui egen `outcome'_wk`i'd_r = max(tmp), by(opening_sat_date dow)
	drop tmp
}
*gen `outcome'_wkn1_r = `outcome'_wk2_r + `outcome'_wk3_r + `outcome'_wk4_r + `outcome'_wk5_r + `outcome'_wk6_r
gen `outcome'_wkn1d_r = `outcome'_wk2d_r + `outcome'_wk3d_r + `outcome'_wk4d_r + `outcome'_wk5d_r + `outcome'_wk6d_r

***First IV by week and for all weeks not 1 on 1
* first stage
reg  `outcome'_wk1d_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_`outcome'_2inst.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_2inst.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_2inst.xls, append
********************************
	
********************************
// Choose 3 instruments
********************************
use main/dta/for_analyses.dta, replace

local selected open_res_own_mat5_50_6 open_res_own_mat5_75_0 open_res_own_mat5_10_0 
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
reg  `outcome'_wk1d_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_`outcome'_3inst.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_3inst.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_3inst.xls, append
********************************

*************************************
// in 10 degree increments
*************************************
use main/dta/for_analyses.dta, replace
* set up case
local selected open_res_own_mat10_70_6
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
reg  `outcome'_wk1d_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_`outcome'_10.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_10.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentum_`outcome'_10.xls, append
********************************



**************************************************************************
************************************* END TABLES: LASSOFIRST, BASECASE, LASSOROBUST
**************************************************************************
