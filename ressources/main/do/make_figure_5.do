***********
********** BEGIN FIGURE: Reduced-Form Binscatters ***********

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

forvalues i = 2/6{
	binscatter `outcome'_wk`i'd_r `selected' if wk`i'==1, nquantiles(100) reportreg ///
		title("Week `i'") graphregion(color(ltbluishgray)) ///
		ytitle("") xtitle("") ///
	color(black) mcolors(black) lcolors(black) graphregion(color(white)) bgcolor(white)
	graph save "temp/reduced_form_bin_`i'.gph", replace
}
* all not 1
binscatter  `outcome'_wkn1d_r `selected' if wk1==1, nquantiles(100) reportreg ///
	title("Weeks 2-6") graphregion(color(ltbluishgray)) ///
	ytitle("") xtitle("") ///
	color(black) mcolors(black) lcolors(black) graphregion(color(white)) bgcolor(white)
graph save "temp/reduced_form_bin_all.gph", replace

* combine them all
graph combine "temp/reduced_form_bin_2.gph" ///
	"temp/reduced_form_bin_3.gph" ///
	"temp/reduced_form_bin_4.gph" ///
	"temp/reduced_form_bin_5.gph" ///
	"temp/reduced_form_bin_6.gph" ///
	"temp/reduced_form_bin_all.gph" ///
	, b1title("Residual % Theaters at 75-80 Degrees F in Opening Weekend") l1title("Residual Ticket Sales (1,000,000s)") ///
	altshrink
graph export "graphics/reduced_form_combine.pdf", replace

rm "temp/reduced_form_bin_2.gph"
rm "temp/reduced_form_bin_3.gph"
rm "temp/reduced_form_bin_4.gph"
rm "temp/reduced_form_bin_5.gph"
rm "temp/reduced_form_bin_6.gph"
rm "temp/reduced_form_bin_all.gph"

********** END FIGURE: REDUCED_FORM_COMBINE.PDF ***********
***********
