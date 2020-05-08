use "local/dta/local_searches_weather", replace

*************** ZSCORES AND RESIDUALS
qui tab id_movie, gen(movie_fe_)

foreach var of varlist h*{
	egen tmph_msa = group(`var' id_msa)
	qui tab tmph_msa, gen(msa_`var'_)
	drop tmph_msa
}

* zscore within msa's
qui sum id_msa
gen z_searches = .
forvalues i = 1/`r(max)'{
	zscore searches if id_msa==`i', stub(tmpz_)
	replace z_searches = tmpz_searches if id_msa==`i'
	drop tmpz*
}


** residualize the outcome variables
foreach var of varlist z_searches {
	gen `var'_res = .
	forvalues i = -2/5{
		qui reg `var' i.dow_msa i.week_of_year_msa i.year_msa msa_h* movie_fe_* if week_num==`i'
		predict tmp if week_num==`i', res
		replace `var'_res = tmp if week_num==`i'
		drop tmp
	}
}

** create 10 degree buckets
forvalues i = 1/9{
	gen mat10_`i'0 = mat5_`i'0+mat5_`i'5
}

** residualize the weather variables
local weathervars snow rain mat* cloud* prec*
foreach var of varlist  `weathervars'{
	gen `var'_res = .
	forvalues i = -2/5{
		qui reg `var' i.dow_msa i.year_msa i.week_of_year_msa msa_h* movie_fe_* if week_num==`i'
		predict tmp, res
		replace `var'_res = tmp if week_num==`i'
		drop tmp
	}
}

* now do opening
local weathervars snow* rain* mat* cloud* prec* 
foreach var of varlist  `weathervars'{
	qui gen tmp = `var' if date==opening_sat_date
	egen open_`var'_6 = max(tmp), by(opening_sat_date id_msa)
	drop tmp
	
	qui gen tmp = `var' if date==opening_sat_date+1
	egen open_`var'_0 = max(tmp), by(opening_sat_date id_msa)
	drop tmp	
	
	qui gen tmp = `var' if date==opening_sat_date-1
	egen open_`var'_5 = max(tmp), by(opening_sat_date id_msa)
	drop tmp	
}

*** compute searches, etc in places further than 1000 km away
* merge on list of far away airports
merge m:1 airport using "local/dta/far_airports"
drop _merge

local listofvars open_mat5_* open_cloud* open_prec* open_snow* open_rain*  ///
	mat5_* mat10_* cloud* prec* snow* rain* mat_la* open_mat_la* ///
	z_searches z_searches_res

* generate empty variables for other
foreach var of varlist  `listofvars'{
	gen other_`var' = .
}

* loop over msa's
qui sum id_msa
forvalues i = 1/`r(max)'{
	* create variable indexing far away airports
	gen far_airports_`i' = far_airports if id_msa == `i'
	gsort -far_airports_`i'
	replace far_airports_`i' = far_airports_`i'[_n-1] if missing(far_airports_`i') & !missing(far_airports_`i'[_n-1])
	
	* get the denominator for the weighted sum
	egen tmp_weight_denom_`i' = sum(establishments * regexm(airport,far_airports_`i')), by(id_movie date)

	* now do the list of variables
	foreach var of varlist `listofvars' {
	
		* first get the sum
		egen tother_`var'_`i' = sum(`var' * regexm(airport,far_airports_`i') * establishments/tmp_weight_denom_`i'), by(id_movie date)
		
		* then hold onto these
		replace other_`var' = tother_`var'_`i' if id_msa==`i'
		
	}
}
drop far_airports_* tmp* tother*
sort id_movie date  airport



************************

*** SET UP FOR ANALYSIS

xtset id_movie_msa date
zscore open_* other*
local weathercontrols mat10_*_res prec_*_res snow_res rain_res


**** set up
*** get wk minus 1 searches
foreach var of varlist z_searches_res {
	gen tmp = `var' if week_num==-1
	egen `var'_wm1 = max(tmp), by(id_movie id_msa dow)
	drop tmp
	
	qui reg `var' `weathercontrols' if week_num == -1
	qui predict tmp if week_num==-1, res
	egen `var'_rwm1 = max(tmp), by(id_movie id_msa dow)
	drop tmp
}

*** get wk0 searches
foreach var of varlist z_searches_res other_z_searches_res {
	gen tmp = `var' if week_num==0
	egen `var'_w0 = max(tmp), by(id_movie id_msa dow)
	drop tmp
}

*** get later week searches controling for weather
foreach var of varlist z_searches_res {
	forvalues i = 1/5{
		qui reg `var' `weathercontrols' if week_num == `i'
		qui predict tmp if week_num==`i', res
		egen `var'_rw`i' = max(tmp), by(id_movie id_msa dow)
		drop tmp
	}
	gen `var'_r_n0 = `var'_rw1 + `var'_rw2 + `var'_rw3 + `var'_rw4 + `var'_rw5
}


* also make w1 controling for w0
reg z_searches_res_w0 z_searches_res_rwm1 if week_num==0
predict z_searches_res_w0m1 if week_num == 0 , res


***** send to matlab
// export to matlab, for week 1 only, standard lasso
local matlab_variables z_searches_res_w0 z_searches_res_w0m1 z_searches_res_rwm1 open_*_res_*

*br `matlab_variables'
outsheet `matlab_variables' using matlab/data/local_daily.csv if week_num==0, delim(",") replace


save "local/dta/local_searches_weather_resid", replace
