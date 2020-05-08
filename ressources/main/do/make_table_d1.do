**************************************************************************
************************************* BEGIN TABLES: 
* Supply-Side Adjustments 
* (AKA: SUPPLY)
**************************************************************************

********************************
// NUMBER OF SCREENS
********************************

use main/dta/for_analyses.dta, clear
drop theaters_wk1_r
local selected open_res_own_mat5_75_0 
local selected_ownweather own_mat10_* own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome theaters

* controls
local controls1 ww* yy* h*

ren tickets_wk1_r tix
egen tickets_wk1_r = sum(tix), by(opening_sat_date sat_date)
drop tix

** do this at weekly level
keep if dow==5 

replace tickets_wk1_r=10*tickets_wk1_r

* get residual tickets controling for own weather for weeks 2+
qui reg `outcome' `controls1' `selected_ownweather' if wk1==1
qui predict tmp if wk1==1, r
qui egen `outcome'_wk1_r = max(tmp), by(opening_sat_date)
drop tmp

forvalues i = 2/6{
	qui reg `outcome' `controls1' `selected_ownweather' if wk`i'==1
	qui predict tmp if wk`i'==1, r
	qui egen `outcome'_wk`i'_r = max(tmp), by(opening_sat_date)
	drop tmp
}

gen `outcome'_wkn1_r = `outcome'_wk2_r + `outcome'_wk3_r + `outcome'_wk4_r + `outcome'_wk5_r + `outcome'_wk6_r


***First IV by week and for all weeks not 1 on 1
*first stage
reg  tickets_wk1_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'_r (tickets_wk1_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 tickets_wk1_r using tab/momentum_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1_r (tickets_wk1_r = `selected') if wk2==1, cluster($clus)
outreg2 tickets_wk1_r using tab/momentum_`outcome'.xls, append
********************************


********************************
// TICKETS PER SCREEN
********************************
use main/dta/for_analyses.dta, clear
* set up case
local selected open_res_own_mat5_75_0
local selected_ownweather own_mat10_10 own_mat10_20 own_mat10_30 own_mat10_40 own_mat10_50 own_mat10_60 own_mat10_70 own_mat10_80 own_mat10_90 own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets_pt

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
reg  tickets_wk1d_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (tickets_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 tickets_wk1d_r using tab/momentum_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (tickets_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 tickets_wk1d_r using tab/momentum_`outcome'.xls, append

********************************
// use data including truncated movies
********************************
use main/dta/for_analyses_incl_trunc.dta, clear
gen dn=date-opening_sat_date+2
tsset opening_sat_date dn
tsfill, full
sort opening_sat_date dn


replace date=dn-2+opening_sat_date if date==.

foreach var of varlist open_res_own_mat5_65_0 own_mat10_10 own_mat10_20 own_mat10_30 own_mat10_40 own_mat10_50 own_mat10_60 own_mat10_70 own_mat10_80 own_mat10_90 own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5 ww* yy* h* dow_* dow{
	egen tmp=max(`var'), by(date)
	replace `var'=tmp if `var'==.
	drop tmp
}

keep if dow==5|dow==6|dow==0

replace wk1=(dn==1|dn==2|dn==3) if wk1==.
replace wk2=(dn==8|dn==9|dn==10) if wk2==.
replace wk3=(dn==15|dn==16|dn==17) if wk3==.
replace wk4=(dn==22|dn==23|dn==24) if wk4==.
replace wk5=(dn==29|dn==30|dn==31) if wk5==.
replace wk6=(dn==36|dn==37|dn==38) if wk6==.



foreach var of varlist tickets tickets_pt{
	replace `var'=0 if `var'==.
}

foreach var of varlist tickets_wk1d_r tickets_wk1_r{
	egen tmp=max(`var'), by(opening_sat_date)
	replace `var'=tmp if `var'==.
	drop tmp
}
	
	
********************************
// BASE CASE WITH TRUNCATED DATA
********************************
local selected open_res_own_mat5_75_0
local selected_ownweather own_mat10_10 own_mat10_20 own_mat10_30 own_mat10_40 own_mat10_50 own_mat10_60 own_mat10_70 own_mat10_80 own_mat10_90 own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets


* controls
local controls1 ww* yy* h* dow_*

sum `selected' `selected_ownweather' `controls' `outcome' opening_sat_date dow

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
outreg2 `selected' using tab/momentumTRUNC_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (`outcome'_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 `outcome'_wk1d_r using tab/momentumTRUNC_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (`outcome'_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 `outcome'_wk1d_r using tab/momentumTRUNC_`outcome'.xls, append


********************************
// TICKETS PER SCREEN WITH TRUNCATED DATA
********************************
local selected open_res_own_mat5_75_0
local selected_ownweather own_mat10_10 own_mat10_20 own_mat10_30 own_mat10_40 own_mat10_50 own_mat10_60 own_mat10_70 own_mat10_80 own_mat10_90 own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets_pt

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
reg  tickets_wk1d_r `selected' if wk1==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentumTRUNC_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* second stage
forvalues i = 1/6{
	ivreg2 `outcome'_wk`i'd_r (tickets_wk1d_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 tickets_wk1d_r using tab/momentumTRUNC_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1d_r (tickets_wk1d_r = `selected') if wk2==1, cluster($clus)
outreg2 tickets_wk1d_r using tab/momentumTRUNC_`outcome'.xls, append
********************************

********************************
// PROBABILITY OF BEING DROPPED
********************************
local selected open_res_own_mat5_75_0  
local selected_ownweather own_mat10_* own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome probdropped

gen probdropped=.
forval i=2/6{
	replace probdropped=probdropped_wk`i' if wk`i'==1
	replace probdropped=0 if probdropped_wk`i'==.
}

ren tickets_wk1_r tix
egen tickets_wk1_r = sum(tix), by(opening_sat_date sat_date)
drop tix
replace tickets_wk1_r = tickets_wk1_r*10

keep if dow==5

* controls
local controls1 ww* yy* h*

* get residual tickets controling for own weather for weeks 2+
gen `outcome'_r=.

forvalues i = 2/6{
	qui reg `outcome' `controls1' `selected_ownweather' if wk`i'==1
	qui predict tmp if wk`i'==1, r
	replace `outcome'_r = tmp if wk`i'==1
	qui egen `outcome'_wk`i'_r = max(tmp), by(opening_sat_date) 
	drop tmp
}

gen `outcome'_wkn1_r = `outcome'_wk2_r + `outcome'_wk3_r + `outcome'_wk4_r + `outcome'_wk5_r + `outcome'_wk6_r

* run the first stage
reg tickets_wk1_r `selected' if wk2==1, cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/momentum_`outcome'.xls, replace ///
	addstat("F-stat", `f_stat')

* wknds: weeks 1-6 on 1
forvalues i = 2/6{
	ivreg2 `outcome'_wk`i'_r (tickets_wk1_r = `selected') if wk`i'==1, cluster($clus)
	outreg2 tickets_wk1_r using tab/momentum_`outcome'.xls, append
}

* all weeks not 1 on 1
ivreg2 `outcome'_wkn1_r (tickets_wk1_r = `selected') if wk2==1, cluster($clus)
outreg2 tickets_wk1_r using tab/momentum_`outcome'.xls, append

********************************

**************************************************************************
************************************* END TABLES: SUPPLY
**************************************************************************
