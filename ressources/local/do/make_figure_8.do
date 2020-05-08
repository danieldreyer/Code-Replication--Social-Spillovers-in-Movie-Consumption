** BEGIN FIGURE 8: Local Reduced-Form Binscatters

use  "local/dta/local_searches_weather_resid", replace

**** MAKE THE PLOTS

local main_instrument z_open_mat5_85_res_6

** plot the reduced form of the second stage
forvalues i = 1/5{
	local j = `i'+1
	binscatter z_searches_res_rw`i' `main_instrument' if week_num==0, nquantiles(100) reportreg ///
		title("Week `j'") graphregion(color(ltbluishgray)) ///
		ytitle("") xtitle("") ///
	color(black) mcolors(black) lcolors(black) graphregion(color(white)) bgcolor(white)
	graph save "temp/local_reduced_form_bin_`j'.gph", replace
}
* all not 1
binscatter  z_searches_res_r_n0 `main_instrument' if week_num==0, nquantiles(100) reportreg ///
	title("Weeks 2-6") graphregion(color(ltbluishgray)) ///
	ytitle("") xtitle("") ///
	color(black) mcolors(black) lcolors(black) graphregion(color(white)) bgcolor(white)
graph save "temp/local_reduced_form_bin_all.gph", replace

* combine them all
graph combine "temp/local_reduced_form_bin_2.gph" ///
	"temp/local_reduced_form_bin_3.gph" ///
	"temp/local_reduced_form_bin_4.gph" ///
	"temp/local_reduced_form_bin_5.gph" ///
	"temp/local_reduced_form_bin_6.gph" ///
	"temp/local_reduced_form_bin_all.gph" ///
	, b1title("Residual Indicator for Temperature 85-90 Deg F on Opening Wkd (Z-score)") l1title("Residual Local Opening Daily Searches (Z-score)") ///
	rows(2) altshrink
graph export "graphics/local_reduced_form_combine.pdf", replace

rm temp/local_reduced_form_bin_2.gph
rm temp/local_reduced_form_bin_3.gph
rm temp/local_reduced_form_bin_4.gph
rm temp/local_reduced_form_bin_5.gph
rm temp/local_reduced_form_bin_6.gph
rm temp/local_reduced_form_bin_all.gph
