
***********
********** BEGIN FIGURE: First Stage Binscatter ***********

use main/dta/for_analyses.dta, replace

local selected open_res_own_mat5_75_0
local outcome tickets

replace `selected' = `selected'*100
reg `outcome'_wk1d_r `selected' if wk1==1, r
binscatter `outcome'_wk1d_r `selected' if wk1==1, nquantiles(100) reportreg ///
	ytitle("Residual Ticket Sales (1,000,000s)") xtitle("Residual % Theaters at 75-80 degrees") ///
	graphregion(color(ltbluishgray)) text(1 20 "Coef: -3.04" "SE: 0.49", place(sw)) ///
	color(black) mcolors(black) lcolors(black) graphregion(color(white)) bgcolor(white)

graph export "graphics/firststagebin.pdf", replace

********** END FIGURE: FIRSTSTAGEBIN.PDF ***********
***********
