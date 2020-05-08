
***********
********** BEGIN FIGURE: Histogram of the Instrument ***********
***********
use main/dta/for_analyses.dta, replace

local selected open_res_own_mat5_75_0   

hist `selected', xtitle("Residual % Theaters at 75-80 degrees In Opening Weekend")  
graph export "graphics/insthist.pdf", replace

***********
********** END FIGURE: INSTHIST.PDF ***********
***********
