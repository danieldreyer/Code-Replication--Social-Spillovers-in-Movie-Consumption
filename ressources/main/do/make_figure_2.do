***********
********** BEGIN FIGURE: The Effect of Weather Shocks on Viewership ***********
***********

use main/dta/for_analyses.dta, clear

keep if wk1==1

zscore tickets_wk1d_r

**** Do it only in levels and z-scores separately
foreach var of varlist open_res_own_mat5_60_0 ///
	open_res_own_mat5_65_0 open_res_own_mat5_70_0 open_res_own_mat5_75_0 ///
	open_res_own_mat5_80_0 open_res_own_mat5_85_0 open_res_own_mat5_90_0 {

	reg tickets_wk1d_r `var', r
	estimates store `var'

	zscore `var'
	reg z_tickets_wk1d_r z_`var', r
	estimates store z_`var'
}

coefplot open_res_own_mat5_60_0 ///
	open_res_own_mat5_65_0 open_res_own_mat5_70_0 open_res_own_mat5_75_0 ///
	open_res_own_mat5_80_0 open_res_own_mat5_85_0 open_res_own_mat5_90_0, mcolor(dknavy)  ///
	drop(_cons) legend(off) ///
	vertical ytitle("Residual Opening Daily Ticket Sales (1,000,000s)") xtitle("Residual Temperature Range (F, levels)") ///
	recast(connected) ciopts(recast(rcap) color(gs10)) nooffsets title("A. in Levels") ///
	coeflabels(open_res_own_mat5_60_0="60-65" open_res_own_mat5_65_0="65-70" ///
	open_res_own_mat5_70_0="70-75" open_res_own_mat5_75_0="75-80" open_res_own_mat5_80_0="80-85" open_res_own_mat5_85_0="85-90" open_res_own_mat5_90_0="90-95") ///
	msymbol(C) mcolor(black)
gr save "temp/firststagelevel.gph", replace

coefplot z_open_res_own_mat5_60_0 ///
	z_open_res_own_mat5_65_0 z_open_res_own_mat5_70_0 z_open_res_own_mat5_75_0 ///
	z_open_res_own_mat5_80_0 z_open_res_own_mat5_85_0 z_open_res_own_mat5_90_0, mcolor(dknavy)  ///
	drop(_cons) legend(off) title("B. in Z-Scores") ///
	vertical ytitle("Residual Opening Daily Ticket Sales (Z-Score)") xtitle("Residual Temperature Range (F, Z-Score)") ///
	recast(connected) ciopts(recast(rcap) color(gs10)) nooffsets ///
	coeflabels(z_open_res_own_mat5_60_0="60-65" z_open_res_own_mat5_65_0="65-70" ///
	z_open_res_own_mat5_70_0="70-75" z_open_res_own_mat5_75_0="75-80" z_open_res_own_mat5_80_0="80-85" z_open_res_own_mat5_85_0="85-90" z_open_res_own_mat5_90_0="90-95")  ///
	msymbol(C) mcolor(black)
gr save "temp/firststagez.gph", replace

graph combine "temp/firststagelevel.gph" "temp/firststagez.gph", altshrink xsize(8)
graph export "graphics/firststageboth.pdf", replace

rm temp/firststagelevel.gph
rm temp/firststagez.gph

***********
********** END FIGURE: FIRSTSTAGEBOTH.PDF ***********
***********
