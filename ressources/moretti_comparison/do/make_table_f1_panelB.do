use moretti_comparison/dta/moretti_data_combined_table_f1_panelB, replace

** IV regressions
local mor_weather_base_res tmin*_res tmax*_res
local mor_weather_all_res tmin*_res tmax*_res prcp*_res snow*_res
local mor_weather_base_squared_res tmin*_res tmax*_res sq_tmin*_res sq_tmax*_res
local mor_weather_all_squared_res prcp*_res snow*_res tmin*_res tmax*_res sq_prc*_res sq_sno*_res sq_tmin*_res sq_tmax*_res

** basic instruments, not squared
ivreg2 sales2_w1_res (sales2_w0_res = `mor_weather_base_res') if t==0, r cluster(opening_sat_date)
outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, replace addstat("f-stat", e(widstat))
forvalues i = 2/5{
	ivreg2 sales2_w`i'_res (sales2_w0_res = `mor_weather_base_res') if t==0, r cluster(opening_sat_date)
	outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append
}
ivreg2 sales2_wn1_res (sales2_w0_res = `mor_weather_base_res') if t==0, r cluster(opening_sat_date)
outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append
	
** basic instruments, squared
ivreg2 sales2_w1_res (sales2_w0_res = `mor_weather_base_squared_res') if t==0, r cluster(opening_sat_date)
outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append addstat("f-stat", e(widstat))
forvalues i = 2/5{
	ivreg2 sales2_w`i'_res (sales2_w0_res = `mor_weather_base_squared_res') if t==0, r cluster(opening_sat_date)
	outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append
}
ivreg2 sales2_wn1_res (sales2_w0_res = `mor_weather_base_squared_res') if t==0, r cluster(opening_sat_date)
outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append
	
** all instruments, not squared
ivreg2 sales2_w1_res (sales2_w0_res = `mor_weather_all_res') if t==0, r cluster(opening_sat_date)
outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append addstat("f-stat", e(widstat))
forvalues i = 2/5{
	ivreg2 sales2_w`i'_res (sales2_w0_res = `mor_weather_all_res') if t==0, r cluster(opening_sat_date)
	outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append
}
ivreg2 sales2_wn1_res (sales2_w0_res = `mor_weather_all_res') if t==0, r cluster(opening_sat_date)
outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append
	
** all instruments, squared
ivreg2 sales2_w1_res (sales2_w0_res = `mor_weather_all_squared_res') if t==0, r cluster(opening_sat_date)
outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append addstat("f-stat", e(widstat))
forvalues i = 2/5{
	ivreg2 sales2_w`i'_res (sales2_w0_res = `mor_weather_all_squared_res') if t==0, r cluster(opening_sat_date)
	outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append
}
ivreg2 sales2_wn1_res (sales2_w0_res = `mor_weather_all_squared_res') if t==0, r cluster(opening_sat_date)
outreg2 sales2_w0_res using tab/morettidata_ourmodel.xls, append	
