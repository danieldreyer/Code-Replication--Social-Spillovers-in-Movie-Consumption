*************************************
// COLLAPSE MOVIES
*************************************

use main/dta/films_day.dta, replace

* NOTE: this file is same as collapse_merge_national.do with the following line commented out
//* drop movies which are dropped before their sixth weekend
//drop if dropped==1

// first collapse to opening sat date by date
collapse (sum) tick* theaters rh1000 rl1000 vtop1000 (mean) h* wk* dow sat_date probdropped_wk*, by(opening_sat_date date)

// and create tickets per theater measures
foreach var of varlist rh1000 rl1000 vtop1000 {
	replace `var'=`var'/theaters
}

save temp/tick_openwkend_day1.dta, replace

* when collapsed, add in holidays from opening weekend
use main/dta/holidays.dta, replace
gen dow=dow(date)

gen opening_sat_date=date if dow==6
replace opening_sat_date=date+1 if dow==5
replace opening_sat_date=date-1 if dow==0
replace opening_sat_date=date-2 if dow==1
drop if opening_sat_date==.

collapse (sum) h*, by(opening_sat_date)
keep opening_sat_date h*
foreach var of varlist h*{
	replace `var'=1 if `var'>0
	rename `var' open`var'
}

merge 1:m opening_sat_date using temp/tick_openwkend_day1.dta
keep if _merge==3
drop _merge

foreach var of varlist h*{
	replace `var'=1 if `var'!=0 & `var'!=.
}

*make theater measures consistent within weekend
ren theaters th
egen theaters=max(th), by(opening_sat_date sat_date)
drop th

*create opening wkend ticket measures
gen tmp=theaters if wk1==1
egen theaterso=max(tmp), by(opening_sat_date)
drop tmp

* create tickets per opening theater, per theater
gen tickets_pot=(tickets*10000/theaterso)
gen tickets_pt=(tickets*10000/theaters)	
	
save temp/tick_openwkend_day2, replace

*************************************
// MERGE WEATHER
*************************************
use temp/tick_openwkend_day2, replace

// merge with collapsed weather for all days
mmerge date using main/dta/weather_collapsed_day.dta

drop if _merge == 2
drop _merge

// mark that as own weather
foreach var of varlist mat_la* mat5_* prec_* snow rain cloud_* { 
	rename `var' own_`var'
}
save temp/tick_openwkend_day3, replace

// load ticket data (w collapsed own weekend weather), add opening weekend weather
use main/dta/weather_collapsed_all, clear

ren sat_date opening_sat_date
merge 1:m opening_sat_date using temp/tick_openwkend_day3
drop if _merge==1
drop _merge

// mark as opening weather
foreach var of varlist  mat_la* mat5_* prec_* snow* rain* cloud_* {
	rename `var' open_`var'
}

// create time variables
gen week = week(sat_date)
gen year = year(sat_date)

// dummy out time variables (to make them usable in ivreg2)
tab week, gen(ww)
tab year, gen(yy)
tab dow, gen(dow_)

//compress and save
compress
save temp/tick_openwkend_day4, replace


*************************************
// PREPARE THE INSTRUMENTS AND OUTPUT FOR MATLAB
*************************************
use temp/tick_openwkend_day4, clear

// create 10 degree increments
forvalues i = 1/9{
	gen own_mat10_`i'0 = own_mat5_`i'0+own_mat5_`i'5
}

* base case fixed effects
local controls1 ww* yy* h* dow_*

* tickets that we want to analyze
local tickets_of_interest tickets ///
	tickets_ratedgpg tickets_adult ///
	tickets_p33_highbudget tickets_p33_lowbudget ///
	tickets_p33_hr1000 tickets_p33_lr1000  ///
	tickets_pt tickets_pot


// get residual tickets by day for all types of tickets, wk1 only
foreach var of varlist `tickets_of_interest' theaters {
	qui reg `var' `controls1' if wk1==1 & `var' > 0
	qui predict tmp if wk1==1 & `var' > 0, r
	
	egen `var'_wk1d_r = max(tmp), by(opening_sat_date dow)

	qui egen `var'_wk1_r = sum(tmp), by(opening_sat_date)
	drop tmp
}

foreach var of varlist rh1000 rl1000 vtop1000 {
	qui reg `var' `controls1' if wk1==1
	qui predict tmp if wk1==1, r
	
	egen `var'_wk1d_r = max(tmp), by(opening_sat_date dow)

	qui egen `var'_wk1_r = sum(tmp), by(opening_sat_date)
	drop tmp
}

// get residual weather
foreach var of varlist own_*{
	qui reg `var' `controls1'
	qui predict res_`var', r
}

// create weather residuals by date
foreach var of varlist res_own*{
	qui gen tmp = `var' if dow==5
	egen `var'_5 = max(tmp), by(sat_date)
	drop tmp
	
	qui gen tmp = `var' if dow==6
	egen `var'_6 = max(tmp), by(sat_date)
	drop tmp
	
	qui gen tmp = `var' if dow==0
	egen `var'_0 = max(tmp), by(sat_date)
	drop tmp	
}

// create opening weather residuals
drop open_*
foreach var of varlist res_own*{
	qui gen tmp = `var' if wk1==1 & dow==5
	egen open_`var'_5 = max(tmp), by(opening_sat_date)
	drop tmp
	
	qui gen tmp = `var' if wk1==1 & dow==6
	egen open_`var'_6 = max(tmp), by(opening_sat_date)
	drop tmp
	
	qui gen tmp = `var' if wk1==1 & dow==0
	egen open_`var'_0 = max(tmp), by(opening_sat_date)
	drop tmp	
}

******* Export to matlab
// export to matlab, for week 1 only
local matlab_variables tickets*_wk1d_r res_own_* 
outsheet `matlab_variables' using matlab/data/opening_wkend.csv if wk1==1, delim(",") replace

// export stuff for clustered lasso to matlab
preserve
foreach var of varlist own*{
	qui gen tmp = `var' if wk1==1 & dow==5
	egen `var'_5 = max(tmp), by(opening_sat_date)
	drop tmp
	
	qui gen tmp = `var' if wk1==1 & dow==6
	egen `var'_6 = max(tmp), by(opening_sat_date)
	drop tmp
	
	qui gen tmp = `var' if wk1==1 & dow==0
	egen `var'_0 = max(tmp), by(opening_sat_date)
	drop tmp	
}
egen opening_wkend_group = group(opening_sat_date)
local matlab_variables tickets own_* ww* yy* h* dow_* opening_wkend_group
outsheet `matlab_variables' using matlab/data/opening_wkend_clus.csv if wk1==1, delim(",") replace
restore

save main/dta/for_analyses.dta, replace

rm temp/tick_openwkend_day1.dta
rm temp/tick_openwkend_day2.dta
rm temp/tick_openwkend_day3.dta
rm temp/tick_openwkend_day4.dta
