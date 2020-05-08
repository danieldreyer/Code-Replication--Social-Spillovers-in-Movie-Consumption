use  "local/dta/local_searches_weather_resid_nofe", replace

****************************************
************ first stage
****************************************
reg z_searches_res_w0 z_open_mat5_85_res_6 if week_num==0,r cluster(date)
test z_open_mat5_85_res_6
local fstat `r(F)'
outreg2 z_open_mat5_85_res_6 using tab/fs_local_nofe.xls, addstat("f-stat",`fstat') replace 


****************************************
************* IV
****************************************
local main_instrument z_open_mat5_85_res_6 
ivreg2 z_searches_res_rw1 (z_searches_res_w0 = `main_instrument') if week_num==0,r cluster(date) first
outreg2 z_searches_res_w0 using "tab/momentum_base_results_nofe.xls", replace
forvalues i = 2/5{
	ivreg2 z_searches_res_rw`i' (z_searches_res_w0 = `main_instrument') if week_num==0,r first cluster(date)
	outreg2 z_searches_res_w0 using "tab/momentum_base_results_nofe.xls", append
}
ivreg2 z_searches_res_r_n0 (z_searches_res_w0 = `main_instrument') if week_num==0,r first cluster(date)
outreg2 z_searches_res_w0 using "tab/momentum_base_results_nofe.xls", append

**********************************************************************
**************** OLS
**********************************************************************
ivreg2 z_searches_res_rw1 z_searches_res_w0 if week_num==0,r cluster(date)
outreg2 z_searches_res_w0 using "tab/momentum_base_results_nofe_ols.xls", replace
forvalues i = 2/5{
	ivreg2 z_searches_res_rw`i' z_searches_res_w0 if week_num==0,r cluster(date)
	outreg2 z_searches_res_w0 using "tab/momentum_base_results_nofe_ols.xls", append
}
ivreg2 z_searches_res_r_n0 z_searches_res_w0 if week_num==0,r cluster(date)
outreg2 z_searches_res_w0 using "tab/momentum_base_results_nofe_ols.xls", append
