***********
********** BEGIN FIGURE: Network Externalities by Movie Age Suitability  ***********
***********
use main/dta/for_analyses.dta, clear

local selected_ownweather own_mat10_* own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5
local controls1 ww* yy* h* dow_*

*****************
** rated G, PG
*****************
local outcome tickets_ratedgpg
local selected open_res_own_prec_0_6

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

* second stage
gen wk1dr=`outcome'_wk1d_r
forvalues i = 2/6{
	rename wk1dr wk1dr_`i'
	ivreg2 `outcome'_wk`i'd_r (wk1dr_`i' = `selected') if wk`i'==1, cluster($clus)
	outreg2 wk1dr_`i' using tab/momentum_`outcome'.xls, append
	estimates store `outcome'`i'
}

*****************
** rated adult
*****************
local outcome tickets_adult
local selected open_res_own_mat5_75_0

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

* second stage
replace wk1dr=`outcome'_wk1d_r
forvalues i = 2/6{
	rename wk1dr wk1dr_`i'
	ivreg2 `outcome'_wk`i'd_r (wk1dr_`i' = `selected') if wk`i'==1, cluster($clus)
	outreg2 wk1dr_`i' using tab/momentum_`outcome'.xls, append
	estimates store `outcome'`i'
}

*****************
** combine
*****************
coefplot (tickets_ratedgpg2 \ tickets_ratedgpg3 \ tickets_ratedgpg4 \ tickets_ratedgpg5 \ tickets_ratedgpg6, label(Child-Friendly Movies))  ///
  (tickets_adult2 \ tickets_adult3 \ tickets_adult4 \ tickets_adult5 \ tickets_adult6, label(Adults-Only Movies) lpattern(dash) msymbol(T)), ///
  drop(_cons) vertical ytitle(Estimated Audience Momentum) xtitle(Weekend in Theaters) recast(connected) nooffsets noci ///
  coeflabels(wk1dr_2="2" wk1dr_3="3" wk1dr_4="4" wk1dr_5="5" wk1dr_6="6") legend(rows(1) size(small))  ///
	msymbol(C) mcolor(black)
 graph export "graphics/bympaagraph.pdf", replace
  
  
***********
********** END FIGURE: Network Externalities by Movie Age Suitability  ***********
***********
