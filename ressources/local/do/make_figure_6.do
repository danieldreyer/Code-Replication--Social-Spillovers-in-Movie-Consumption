* BEGIN FIGURE:
* The Effect of Local Weather Shocks on Local Viewership

use  "local/dta/local_searches_weather_resid", replace

**** FIRST STAGE BY CITY
** NYC
foreach var of varlist z_open_mat5_60_res_6 ///
	z_open_mat5_65_res_6 z_open_mat5_70_res_6 z_open_mat5_75_res_6 ///
	z_open_mat5_80_res_6 z_open_mat5_85_res_6 z_open_mat5_90_res_6 {
	reg z_searches_res `var' z_searches_res_rwm1 if week_num==0 & id_msa==1, r cluster(date)
	estimates store `var'
}
coefplot z_open_mat5_60_res_6 ///
	z_open_mat5_65_res_6 z_open_mat5_70_res_6 z_open_mat5_75_res_6 ///
	z_open_mat5_80_res_6 z_open_mat5_85_res_6 z_open_mat5_90_res_6, mcolor(dknavy)  ///
	keep(z_open*) legend(off) ///
	vertical title("A. New York City") ///
	recast(connected) ciopts(recast(rcap) color(gs10)  ) nooffsets ///
	coeflabels(z_open_mat5_60_res_6="60-65" z_open_mat5_65_res_6="65-70" ///
	z_open_mat5_70_res_6="70-75" z_open_mat5_75_res_6="75-80" z_open_mat5_80_res_6="80-85" ///
	z_open_mat5_85_res_6="85-90" z_open_mat5_90_res_6="90-95")  ///
	msymbol(C) mcolor(black)
graph save "temp/ff_local_1.gph", replace

** LA
foreach var of varlist z_open_mat5_60_res_6 ///
	z_open_mat5_65_res_6 z_open_mat5_70_res_6 z_open_mat5_75_res_6 ///
	z_open_mat5_80_res_6 z_open_mat5_85_res_6 z_open_mat5_90_res_6 {
	reg z_searches_res `var' z_searches_res_rwm1 if week_num==0 & id_msa==2, r cluster(date)
	estimates store `var'
}
coefplot z_open_mat5_60_res_6 ///
	z_open_mat5_65_res_6 z_open_mat5_70_res_6 z_open_mat5_75_res_6 ///
	z_open_mat5_80_res_6 z_open_mat5_85_res_6 z_open_mat5_90_res_6, mcolor(dknavy)  ///
	keep(z_open*) legend(off) ///
	vertical title("B. Los Angeles") ///
	recast(connected) ciopts(recast(rcap) color(gs10)) nooffsets ///
	coeflabels(z_open_mat5_60_res_6="60-65" z_open_mat5_65_res_6="65-70" ///
	z_open_mat5_70_res_6="70-75" z_open_mat5_75_res_6="75-80" z_open_mat5_80_res_6="80-85" ///
	z_open_mat5_85_res_6="85-90" z_open_mat5_90_res_6="90-95")  ///
	msymbol(C) mcolor(black)
graph save "temp/ff_local_2.gph", replace

* all
foreach var of varlist z_open_mat5_60_res_6 ///
	z_open_mat5_65_res_6 z_open_mat5_70_res_6 z_open_mat5_75_res_6 ///
	z_open_mat5_80_res_6 z_open_mat5_85_res_6 z_open_mat5_90_res_6 {
	reg z_searches_res `var' z_searches_res_rwm1 if week_num==0, r cluster(date)
	estimates store `var'
}
coefplot z_open_mat5_60_res_6 ///
	z_open_mat5_65_res_6 z_open_mat5_70_res_6 z_open_mat5_75_res_6 ///
	z_open_mat5_80_res_6 z_open_mat5_85_res_6 z_open_mat5_90_res_6, mcolor(dknavy)  ///
	keep(z_open*) legend(off) ///
	vertical  title("C. All") ///
	recast(connected) ciopts(recast(rcap) color(gs10)) nooffsets ///
	coeflabels(z_open_mat5_60_res_6="60-65" z_open_mat5_65_res_6="65-70" ///
	z_open_mat5_70_res_6="70-75" z_open_mat5_75_res_6="75-80" z_open_mat5_80_res_6="80-85" ///
	z_open_mat5_85_res_6="85-90" z_open_mat5_90_res_6="90-95")  ///
	msymbol(C) mcolor(black)
graph save "temp/ff_local_all.gph", replace

* combine
graph combine "temp/ff_local_1.gph" ///
	"temp/ff_local_2.gph" ///
	"temp/ff_local_all.gph" ///
	, b1title("Residual Temperature Range on Opening Weekend (Degrees F, Z-score)") ///
	l1title("Residual Opening Daily Searches (Z-score)") rows(1) xsize(10) altshrink ycommon
graph export "graphics/firstbothlocal.pdf", replace

rm temp/ff_local_1.gph
rm temp/ff_local_2.gph
rm temp/ff_local_all.gph
