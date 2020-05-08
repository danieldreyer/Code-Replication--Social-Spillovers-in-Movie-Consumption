**************************************************************************
************************************* BEGIN TABLES:
* Substitution across Movies and Activities 
* (aka: SUBSTITUTION)
**************************************************************************
use main/dta/for_analyses.dta, clear

* set up case
local selected open_res_own_mat5_75_0
local selected_ownweather own_mat10_* own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local outcome tickets

* controls
local controls1 ww* yy* h* dow_*

* get residual overall sales by date
egen tickets_all = sum(tickets), by(date)
qui reg tickets_all `controls1'
qui predict tickets_all_r, r

qui reg tickets_all `controls1' `selected_ownweather'
qui predict tickets_all_rw, r

* get residual ticket sales if this is week 1-5 and then 2-6 controling for own weather
egen tickets_wk15 = sum(tickets*(wkintheaters>=1 & wkintheaters<=5)), by(date)
qui reg tickets_wk15 `controls1'
qui predict tickets_wk15_r, r

egen tickets_wk26 = sum(tickets*(wkintheaters>=2 & wkintheaters<=6)), by(date)
qui reg tickets_wk26 `controls1' `selected_ownweather'
qui predict tickets_wk26_r, res

* and also week 2 tickets
reg tickets `controls1' `selected_ownweather' if wk2==1
predict tmp if wk2==1, res
egen tickets_wk2_r = max(tmp), by(date)
drop tmp

* line up wk2 tix with wk1
foreach var of varlist tickets_wk2_r {
	gen tmp = `var' if wk2==1
	egen `var'plus7 = max(tmp), by(opening_sat_date dow)
	drop tmp
}

sort date
* keep only opening rows
keep if wk1==1
sort date

* get residual ticket sales for opening contorling for own weather
reg tickets_wk1d_r `selected_ownweather' if wk1==1
predict tickets_wk1d_r2, res

* get opening ticket sales from next weekend so can use in second stage
gen tickets_wk1d_rplus7 = tickets_wk1d_r[_n+3]
gen tickets_wk1d_r2plus7 = tickets_wk1d_r2[_n+3]

* also get tickets for movies 2-6 from next wkend, and overall
gen tickets_wk26_rplus7 = tickets_wk26_r[_n+3]
*gen tickets_wk2_rplus7 = tickets_wk2_r[_n+3]
gen tickets_all_rwplus7 = tickets_all_rw[_n+3]


**** REGRESSIONS
* first-stages
reg  tickets_wk15_r `selected' if !missing(tickets_wk26_rplus7), cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/robust_overall.xls, replace ///
	addstat("F-stat", `f_stat')
reg  tickets_all_r `selected' if !missing(tickets_wk26_rplus7), cluster($clus)
test `selected'
local f_stat `r(F)'
outreg2 `selected' using tab/robust_overall.xls, append ///
	addstat("F-stat", `f_stat')
	
** base case movies in second week on movies in first
ivreg2 tickets_wk2_rplus7 (tickets_wk1d_r = `selected'), first cluster(date)
outreg2 tickets_wk1d_r using tab/robust_overall.xls, append

**** 2-6 on 1st
ivreg2 tickets_wk26_rplus7 (tickets_wk1d_r = `selected'), first cluster($clus)
outreg2 tickets_wk1d_r using tab/robust_overall.xls, append

**** 2-6 on 1-5
ivreg2 tickets_wk26_rplus7 (tickets_wk15_r = `selected'), first cluster($clus)
outreg2 tickets_wk15_r using tab/robust_overall.xls, append
	
****  1st on 1st
ivreg2 tickets_wk1d_r2plus7 (tickets_wk1d_r = `selected'), first cluster($clus)
outreg2 tickets_wk1d_r using tab/robust_overall.xls, append

****  1st on 1-5
ivreg2 tickets_wk1d_r2plus7 (tickets_wk15_r = `selected'), first cluster($clus)
outreg2 tickets_wk15_r using tab/robust_overall.xls, append

****  1-6 on 1st
ivreg2 tickets_all_rwplus7 (tickets_wk1d_r = `selected'), first cluster($clus)
outreg2 tickets_wk1d_r using tab/robust_overall.xls, append
	
****  1-6 on 1-5
ivreg2 tickets_all_rwplus7 (tickets_wk15_r = `selected'), first cluster($clus)
outreg2 tickets_wk15_r using tab/robust_overall.xls, append

**************************************************************************
************************************* END TABLES: SUBSTITUTION
**************************************************************************
