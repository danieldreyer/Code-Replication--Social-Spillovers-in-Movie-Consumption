** use data from our main analysis, merge on moretti's weather measures
use main/dta/for_analyses.dta, replace
merge m:1 date using "moretti_comparison/dta/weather_5cities.dta"
drop if _merge == 2
drop _merge

* controls
local controls1 ww* yy* h* dow_*

* residualize the moretti measures
foreach var of varlist mor_* sq_mor_*{
	gen res_`var' = .
	forvalues i = 1/6{
		qui reg `var' `controls1' if wk`i'==1
		predict tmp, res
		replace res_`var' = tmp if wk`i'==1
		drop tmp
	}
}

* get residual tickets for weeks 2+
local outcome tickets
local selected_ownweather own_mat10_10 own_mat10_20 own_mat10_30 own_mat10_40 own_mat10_50 own_mat10_60 own_mat10_70 own_mat10_80 own_mat10_90 own_snow own_rain own_prec_0 own_prec_1 own_prec_2 own_prec_3 own_prec_4 own_prec_5

gen `outcome'_r=.
forvalues i = 2/6{
	qui reg `outcome' `controls1' `selected_ownweather' if wk`i'==1
	qui predict tmp if wk`i'==1, r
	replace `outcome'_r = tmp if wk`i'==1
	qui egen `outcome'_wk`i'd_r = max(tmp), by(opening_sat_date dow)
	drop tmp
}
gen `outcome'_wkn1d_r = `outcome'_wk2d_r + `outcome'_wk3d_r + `outcome'_wk4d_r + `outcome'_wk5d_r + `outcome'_wk6d_r


****** SET UP THE INSTRUMENTS
local ins_res_mor_matmit res_mor_mat_5_* res_mor_mat_6_* res_mor_mit_5_* res_mor_mit_6_*  // res_mor_mat_5_APA res_mor_mat_6_APA res_mor_mit_5_APA res_mor_mit_6_APA res_mor_mat_5_BOS res_mor_mat_6_BOS res_mor_mit_5_BOS res_mor_mit_6_BOS res_mor_mat_5_DET res_mor_mat_6_DET res_mor_mit_5_DET res_mor_mit_6_DET res_mor_mat_5_MDW res_mor_mat_6_MDW res_mor_mit_5_MDW res_mor_mit_6_MDW res_mor_mat_5_MKC res_mor_mat_6_MKC res_mor_mit_5_MKC res_mor_mit_6_MKC res_mor_mat_5_NYC res_mor_mat_6_NYC res_mor_mit_5_NYC res_mor_mit_6_NYC res_mor_mat_5_PDK res_mor_mat_6_PDK res_mor_mit_5_PDK res_mor_mit_6_PDK
local ins_res_mor_all res_mor_mat_5_* res_mor_mat_6_* res_mor_mit_5_* res_mor_mit_6_* res_mor_snowfall_5_* res_mor_snowfall_6_* res_mor_prec_5_* res_mor_prec_6_* //*  res_mor_mat_5_APA res_mor_mat_6_APA res_mor_mit_5_APA res_mor_mit_6_APA res_mor_prec_5_APA res_mor_prec_6_APA res_mor_snowfall_5_APA res_mor_snowfall_6_APA res_mor_mat_5_BOS res_mor_mat_6_BOS res_mor_mit_5_BOS res_mor_mit_6_BOS res_mor_prec_5_BOS res_mor_prec_6_BOS res_mor_snowfall_5_BOS res_mor_snowfall_6_BOS res_mor_mat_5_DET res_mor_mat_6_DET res_mor_mit_5_DET res_mor_mit_6_DET res_mor_prec_5_DET res_mor_prec_6_DET res_mor_snowfall_5_DET res_mor_snowfall_6_DET res_mor_mat_5_MDW res_mor_mat_6_MDW res_mor_mit_5_MDW res_mor_mit_6_MDW res_mor_prec_5_MDW res_mor_prec_6_MDW res_mor_snowfall_5_MDW res_mor_snowfall_6_MDW res_mor_mat_5_MKC res_mor_mat_6_MKC res_mor_mit_5_MKC res_mor_mit_6_MKC res_mor_prec_5_MKC res_mor_prec_6_MKC res_mor_snowfall_5_MKC res_mor_snowfall_6_MKC res_mor_mat_5_NYC res_mor_mat_6_NYC res_mor_mit_5_NYC res_mor_mit_6_NYC res_mor_prec_5_NYC res_mor_prec_6_NYC res_mor_snowfall_5_NYC res_mor_snowfall_6_NYC res_mor_mat_5_PDK res_mor_mat_6_PDK res_mor_mit_5_PDK res_mor_mit_6_PDK res_mor_prec_5_PDK res_mor_prec_6_PDK res_mor_snowfall_5_PDK res_mor_snowfall_6_PDK
local ins_res_mor_matmit2 res_mor_mat_5_* res_mor_mat_6_* res_mor_mit_5_* res_mor_mit_6_*  res_sq_mor_mat_5_* res_sq_mor_mat_6_* res_sq_mor_mit_5_* res_sq_mor_mit_6_* 
local ins_res_mor_all2 res_mor_mat_5_* res_mor_mat_6_* res_mor_mit_5_* res_mor_mit_6_* res_mor_snowfall_5_* res_mor_snowfall_6_* res_mor_prec_5_* res_mor_prec_6_* res_sq_mor_mat_5_* res_sq_mor_mat_6_* res_sq_mor_mit_5_* res_sq_mor_mit_6_* res_sq_mor_snowfall_5_* res_sq_mor_snowfall_6_* res_sq_mor_prec_5_* res_sq_mor_prec_6_*

outreg2 tickets_wk1d_r using tab/moretti.xls, replace


*** DO THE ANALYSIS
** LINEARLY
* first for mat-mit
* weeks 2-6
forvalues i = 2/6{
	ivreg2 tickets_wk`i'd_r (tickets_wk1d_r = `ins_res_mor_matmit') if wk1==1, cluster(date)
	outreg2 tickets_wk1d_r using tab/moretti.xls, append addstat('f-stat',e(widstat))
}
* all
ivreg2 tickets_wkn1d_r (tickets_wk1d_r = `ins_res_mor_matmit') if wk1==1, cluster(date)
outreg2 tickets_wk1d_r using tab/moretti.xls, append addstat('f-stat',e(widstat))


* second for all weather
* weeks 2-6
forvalues i = 2/6{
	ivreg2 tickets_wk`i'd_r (tickets_wk1d_r = `ins_res_mor_all') if wk1==1, cluster(date)
	outreg2 tickets_wk1d_r using tab/moretti.xls, append addstat('f-stat',e(widstat))
}
* all
ivreg2 tickets_wkn1d_r (tickets_wk1d_r = `ins_res_mor_all') if wk1==1, cluster(date) 
outreg2 tickets_wk1d_r using tab/moretti.xls, append addstat('f-stat',e(widstat))

** QUADRATIC
* first for mat-mit
* weeks 2-6
forvalues i = 2/6{
	ivreg2 tickets_wk`i'd_r (tickets_wk1d_r = `ins_res_mor_matmit2') if wk1==1, cluster(date)
	outreg2 tickets_wk1d_r using tab/moretti.xls, append addstat('f-stat',e(widstat))
}
* all
ivreg2 tickets_wkn1d_r (tickets_wk1d_r = `ins_res_mor_matmit2') if wk1==1, cluster(date)
outreg2 tickets_wk1d_r using tab/moretti.xls, append addstat('f-stat',e(widstat))


* second for all weather
* weeks 2-6
forvalues i = 2/6{
	ivreg2 tickets_wk`i'd_r (tickets_wk1d_r = `ins_res_mor_all2') if wk1==1, cluster(date)
	outreg2 tickets_wk1d_r using tab/moretti.xls, append addstat('f-stat',e(widstat))
}
* all
ivreg2 tickets_wkn1d_r (tickets_wk1d_r = `ins_res_mor_all2') if wk1==1, cluster(date) 
outreg2 tickets_wk1d_r using tab/moretti.xls, append addstat('f-stat',e(widstat))


