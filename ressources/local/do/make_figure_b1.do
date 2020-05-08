** BEGIN FIGURE
* Ticket Sales, National Searches, and the Weather

use local/dta/national_searches.dta, replace

**************************************************
********** analysis
**************************************************

* merge on opening wkend weather
ren sat_date tmp
ren opening_sat_date sat_date
mmerge sat_date using main/dta/weather_collapsed_all.dta
ren sat_date opening_sat_date
ren tmp sat_date
drop if _merge == 2
drop _merge

zscore theaterso searches* tickets* mat5* mat_la_cens* snow* rain* prec* cloud*

** get residuals
* individually
foreach var of varlist z_tickets z_searches z_mat5* z_mat_la_cens* z_snow* z_rain* z_prec* z_cloud* { 
	qui reg `var' i.dow i.week i.year h*
	predict res_`var', res
}
* for weekend level variables (not controling for holidays correctly)
foreach var of varlist z_*_wkend { 
	qui reg `var' i.dow i.week i.year h* if dow == 6
	predict res_`var' if dow == 6, res
}
* taking out movie fixed effects
foreach var of varlist res_z_tickets res_z_searches res_z_tickets_wkend res_z_searches_wkend { 
	qui reg `var' i.id_movie
	predict mf_`var', res
}
* merge on weather
mmerge date using main/dta/weather_collapsed_day.dta
drop if _merge == 2
drop _merge

* residualize weather
zscore mat5_10 mat5_15 mat5_20 mat5_25 mat5_30 mat5_35 mat5_40 mat5_45 mat5_50 mat5_55 mat5_60 mat5_65 mat5_70 mat5_75 mat5_80 mat5_85 mat5_90 mat5_95
foreach var of varlist z_mat5_10 z_mat5_15 z_mat5_20 z_mat5_25 z_mat5_30 z_mat5_35 z_mat5_40 z_mat5_45 z_mat5_50 z_mat5_55 z_mat5_60 z_mat5_65 z_mat5_70 z_mat5_75 z_mat5_80 z_mat5_85 z_mat5_90 z_mat5_95 {
	qui reg `var' i.dow i.week i.year h* 
	predict res_`var', res
}

* and searches-tix res
reg  res_z_tickets res_z_searches, r
predict res_tickets_searches, res

* make plot
foreach var of varlist res_z_mat5_50 res_z_mat5_55 res_z_mat5_60 res_z_mat5_65 res_z_mat5_70 res_z_mat5_75 res_z_mat5_80 res_z_mat5_85 res_z_mat5_90 res_z_mat5_95 {
	reg res_tickets_searches `var', r cluster(date)
	estimates store `var'
}
coefplot /// 
	res_z_mat5_60 res_z_mat5_65 res_z_mat5_70 res_z_mat5_75 res_z_mat5_80 res_z_mat5_85 res_z_mat5_90, ///
	mcolor(dknavy)  ///
	keep(res_z_mat5_*) legend(off) ///
	vertical  ytitle("Residual from Regression of Abnormal Daily Ticket Sales" "on Abnormal National Daily Searches (Z-Scores)") xtitle("Residual Temperature Range (F, Z-Score)") ///
	recast(connected) ciopts(recast(rcap) color(gs10)) nooffsets ///
	coeflabels(res_z_mat5_60="60-65" res_z_mat5_65="65-70" /// 
	res_z_mat5_70="70-75" res_z_mat5_75="75-80" res_z_mat5_80="80-85" res_z_mat5_85="85-90" res_z_mat5_90="90-95")  ///
	msymbol(C) mcolor(black)
graph export "graphics/nattixsearchesweather.pdf", replace
