
use  "local/dta/local_searches_weather_resid", replace

****************************************
************ first stages
****************************************
local main_instrument z_open_mat5_85_res_6 

reg z_searches_res_w0 z_open_mat5_85_res_6 if week_num==0,r cluster(date)
test z_open_mat5_85_res_6
local fstat `r(F)'
outreg2 z_open_mat5_85_res_6 using tab/fs_local.xls, addstat("f-stat",`fstat') replace 

reg z_searches_res_w0 z_open_mat5_85_res_6 z_searches_res_rwm1 if week_num==0,r cluster(date)
test z_open_mat5_85_res_6
local fstat `r(F)'
outreg2 z_open_mat5_85_res_6 using tab/fs_local.xls, addstat("f-stat",`fstat') append 


****************************************
************* IV TIME
****************************************
ivreg2 z_searches_res_rw1 (z_searches_res_w0 = `main_instrument') if week_num==0,r cluster(date) first
outreg2 z_searches_res_w0 using "tab/momentum_base_results.xls", replace
forvalues i = 2/5{
	ivreg2 z_searches_res_rw`i' (z_searches_res_w0 = `main_instrument') if week_num==0,r first cluster(date)
	outreg2 z_searches_res_w0 using "tab/momentum_base_results.xls", append
}
ivreg2 z_searches_res_r_n0 (z_searches_res_w0 = `main_instrument') if week_num==0,r first cluster(date)
outreg2 z_searches_res_w0 using "tab/momentum_base_results.xls", append


************** Controling for wk minus 1
ivreg2 z_searches_res_rw1 z_searches_res_rwm1 (z_searches_res_w0 = `main_instrument') if week_num==0,r cluster(date) first
outreg2 z_searches_res_w0 using "tab/momentum_base_results_wm1.xls", replace
forvalues i = 2/5{
	ivreg2 z_searches_res_rw`i' z_searches_res_rwm1 (z_searches_res_w0 = `main_instrument') if week_num==0,r first cluster(date)
	outreg2 z_searches_res_w0 using "tab/momentum_base_results_wm1.xls", append
}
ivreg2 z_searches_res_r_n0 z_searches_res_rwm1 (z_searches_res_w0 = `main_instrument') if week_num==0,r first cluster(date)
outreg2 z_searches_res_w0 using "tab/momentum_base_results_wm1.xls", append


**********************************************************************
**************** REDO THE ABOVE BUT OLS
**********************************************************************
ivreg2 z_searches_res_rw1 z_searches_res_w0 if week_num==0,r cluster(date)
outreg2 z_searches_res_w0 using "tab/momentum_base_results_ols.xls", replace
forvalues i = 2/5{
	ivreg2 z_searches_res_rw`i' z_searches_res_w0 if week_num==0,r cluster(date)
	outreg2 z_searches_res_w0 using "tab/momentum_base_results_ols.xls", append
}
ivreg2 z_searches_res_r_n0 z_searches_res_w0 if week_num==0,r cluster(date)
outreg2 z_searches_res_w0 using "tab/momentum_base_results_ols.xls", append


************** Controling for wk minus 1
ivreg2 z_searches_res_rw1 z_searches_res_rwm1 z_searches_res_w0 if week_num==0,r cluster(date) first
outreg2 z_searches_res_w0 using "tab/momentum_base_results_wm1_ols.xls", replace
forvalues i = 2/5{
	ivreg2 z_searches_res_rw`i' z_searches_res_rwm1 z_searches_res_w0 if week_num==0,r first cluster(date)
	outreg2 z_searches_res_w0 using "tab/momentum_base_results_wm1_ols.xls", append
}
ivreg2 z_searches_res_r_n0 z_searches_res_rwm1 z_searches_res_w0 if week_num==0,r first cluster(date)
outreg2 z_searches_res_w0 using "tab/momentum_base_results_wm1_ols.xls", append
