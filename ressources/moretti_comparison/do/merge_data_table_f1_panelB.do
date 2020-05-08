** This file uses Moretti 2011's code


use moretti_comparison/dta/moretti_film_data.dta, clear

************************************************************
************************************************************
****************************************
**************************************** get Moretti's sample
****************************************
************************************************************
************************************************************
g       cpi = 96/195 if year ==1982
replace cpi = 99/195 if year ==1983
replace cpi = 103/195 if year ==1984
replace cpi = 107/195 if year ==1985
replace cpi = 109/195 if year ==1986
replace cpi = 113/195 if year ==1987
replace cpi = 118/195 if year ==1988
replace cpi = 124/195 if year ==1989
replace cpi = 130/195 if year ==1990
replace cpi = 136/195 if year ==1991
replace cpi = 140/195 if year ==1992
replace cpi = 144/195 if year ==1993
replace cpi = 148/195 if year ==1994
replace cpi = 152/195 if year ==1995
replace cpi = 156/195 if year ==1996
replace cpi = 160/195 if year ==1997
replace cpi = 163/195 if year ==1998
replace cpi = 166/195 if year ==1999
replace cpi = 172/195 if year ==2000

replace sales = sales/cpi
replace sales2 = sales2/cpi
replace sales_first_weekend = sales_first_weekend/cpi
replace sales_first_week = sales_first_week/cpi
replace cost             = cost/cpi

replace lenght = 100 if lenght ==.
egen mean_cost = mean(cost)
g cost_imputed = (cost ==.)
replace cost = mean_cost if cost ==.
drop mean_cost

g k = (sales >0) 
g k2= (sales2>0)
egen non_zero  = sum(k) , by(id)
egen non_zero2 = sum(k2), by(id)
drop k k2

g t0 = (t==0)
g t1 = (t==1)
g t2 = (t==2)
g t3 = (t==3)
g t4 = (t==4)
g t5 = (t==5)
g t6 = (t==6)
g t7 = (t==7)

by id: g dd = (screens - screens[_n-1])/ screens[_n-1] if t==1 
egen max = max(dd), by(id)
g open_ny_la = (max>5)
drop max

* identifiers for possible typos in sales
g ratio = sales2/sales
egen max = max(ratio), by(id)
g typo = 1 if max >3 & max ~=.
drop max ratio

g ratio = sales_first_weekend/screens_first_week
xtile Q_ratio = ratio,  nquantiles(100)
g       sold_out = (Q_ratio >95)
replace sold_out = . if Q_ratio ==.
drop ratio Q_ratio


*******************************************
*******************************************
* DEFINE SALES
*******************************************
*******************************************
* LOG +1
  g y              = log(sales2 +1)

g y0             = log(sales_first_weekend +1)
replace cost     = log(cost +1)
g screens0       = log(screens_first_week)


*******************************************
*******************************************
* DEFINE SAMPLE
*******************************************
*******************************************
keep if sales_first_week     >0 
keep if sales_first_weekend  >0
keep if screens_first_week   >0
keep if open_ny_la          ==0
keep if typo                ~=1 



save "temp/moretti_film_data_clean.dta", replace



************************************************************
************************************************************
****************************************
**************************************** get Moretti's Weather
****************************************
************************************************************
************************************************************

u  moretti_comparison/dta/moretti_weather_data, replace
g date = mdy(month,day,year)
drop if date ==.
save temp/tmp, replace

u  moretti_comparison/dta/moretti_weather_data, replace
g date = mdy(month,day,year) -1
drop if date ==.

rename tmin8031 tmin8031_1
rename tmax8031 tmax8031_1
rename prcp8031 prcp8031_1
rename snow8031 snow8031_1
rename tmin17031 tmin17031_1
rename tmax17031 tmax17031_1
rename prcp17031 prcp17031_1
rename snow17031 snow17031_1
rename tmin20209 tmin20209_1
rename tmax20209 tmax20209_1
rename prcp20209 prcp20209_1
rename snow20209 snow20209_1
rename tmin25025 tmin25025_1
rename tmax25025 tmax25025_1
rename prcp25025 prcp25025_1
rename snow25025 snow25025_1
rename tmin26163 tmin26163_1
rename tmax26163 tmax26163_1
rename prcp26163 prcp26163_1
rename snow26163 snow26163_1
rename tmin36061 tmin36061_1
rename tmax36061 tmax36061_1
rename prcp36061 prcp36061_1
rename snow36061 snow36061_1

sort date
save temp/tmp2, replace

* merge
u temp/tmp
sort date
merge date using temp/tmp2
keep if _merge==3
drop _merge
*rename date opening_date
*sort opening_date
sort date
save temp/tmp3, replace
rm temp/tmp.dta
rm temp/tmp2.dta



*******************************************
* SQUARED WEATHER
*******************************************
use temp/tmp3, replace

g sq_prcp8031        =   prcp8031               *        prcp8031        
g sq_prcp17031       =   prcp17031              *        prcp17031       
g sq_prcp20209       =   prcp20209              *        prcp20209       
g sq_prcp25025       =   prcp25025              *        prcp25025       
g sq_prcp26163       =   prcp26163              *        prcp26163       
g sq_prcp36061       =   prcp36061              *        prcp36061       
g sq_snow8031        =   snow8031               *        snow8031        
g sq_snow17031       =   snow17031              *        snow17031       
g sq_snow20209       =   snow20209              *        snow20209       
g sq_snow25025       =   snow25025              *        snow25025       
g sq_snow26163       =   snow26163              *        snow26163       
g sq_snow36061       =   snow36061              *        snow36061       
g sq_tmin8031        =   tmin8031               *        tmin8031        
g sq_tmin17031       =   tmin17031              *        tmin17031       
g sq_tmin20209       =   tmin20209              *        tmin20209       
g sq_tmin25025       =   tmin25025              *        tmin25025       
g sq_tmin26163       =   tmin26163              *        tmin26163       
g sq_tmin36061       =   tmin36061              *        tmin36061       
g sq_tmax8031        =   tmax8031               *        tmax8031        
g sq_tmax17031       =   tmax17031              *        tmax17031       
g sq_tmax20209       =   tmax20209              *        tmax20209       
g sq_tmax25025       =   tmax25025              *        tmax25025       
g sq_tmax26163       =   tmax26163              *        tmax26163       
g sq_tmax36061       =   tmax36061              *        tmax36061       
g sq_prcp8031_1      =   prcp8031_1             *        prcp8031_1      
g sq_prcp17031_1     =   prcp17031_1            *        prcp17031_1     
g sq_prcp20209_1     =   prcp20209_1            *        prcp20209_1     
g sq_prcp25025_1     =   prcp25025_1            *        prcp25025_1     
g sq_prcp26163_1     =   prcp26163_1            *        prcp26163_1     
g sq_prcp36061_1     =   prcp36061_1            *        prcp36061_1     
g sq_snow8031_1      =   snow8031_1             *        snow8031_1      
g sq_snow17031_1     =   snow17031_1            *        snow17031_1     
g sq_snow20209_1     =   snow20209_1            *        snow20209_1     
g sq_snow25025_1    =   snow25025_1           *        snow25025_1    
g sq_snow26163_1     =   snow26163_1            *        snow26163_1     
g sq_snow36061_1     =   snow36061_1            *        snow36061_1     
g sq_tmin8031_1      =   tmin8031_1             *        tmin8031_1      
g sq_tmin17031_1     =   tmin17031_1            *        tmin17031_1     
g sq_tmin20209_1    =   tmin20209_1           *        tmin20209_1    
g sq_tmin25025_1     =   tmin25025_1            *        tmin25025_1     
g sq_tmin26163_1     =   tmin26163_1            *        tmin26163_1     
g sq_tmin36061_1     =   tmin36061_1            *        tmin36061_1     
g sq_tmax8031_1      =   tmax8031_1             *        tmax8031_1      
g sq_tmax17031_1     =   tmax17031_1            *        tmax17031_1     
g sq_tmax20209_1     =   tmax20209_1            *        tmax20209_1     
g sq_tmax25025_1     =   tmax25025_1            *        tmax25025_1     
g sq_tmax26163_1     =   tmax26163_1            *        tmax26163_1     
g sq_tmax36061_1     =   tmax36061_1            *        tmax36061_1     

save temp/moretti_weather_data_clean.dta, replace
rm temp/tmp3.dta



************************************************************
************************************************************
****************************************
**************************************** Merge Moretti's data and set up within our framework
****************************************
************************************************************
************************************************************

use temp/moretti_film_data_clean.dta, replace

label var sales "week sales"
label var sales2 "weekend sales"

**** get opening sat date
gen dow = dow(opening_date)
gen opening_sat_date = opening_date + 6 - dow
drop dow
gen sat_date = opening_sat_date + 7*t

format opening_date opening_sat_date sat_date %td

drop week year month
gen week = week(sat_date)
gen year = year(sat_date)

** collapse to weekly
collapse (sum) sales2 (first) week year sat_date, by(opening_sat_date t)

**** add holidays
merge m:1 sat_date using moretti_comparison/dta/holidays_week.dta
drop if _merge == 2
drop _merge

**** add weather for opening_sat_date
ren opening_sat_date date
merge m:1 date using temp/moretti_weather_data_clean.dta
ren date opening_sat_date
drop if _merge == 2
drop _merge

** add weather for sat date
mmerge sat_date using main/dta/weather_collapsed_all.dta
drop if _merge == 2
drop _merge

// mark as own weather
foreach var of varlist mat* prec_* snow_0 snow_5 snow_6 rain* cloud_* {
	rename `var' own_`var'
}

forvalues i = 1/9{
	gen own_mat10_`i'0_5 = own_mat5_`i'0_5+own_mat5_`i'5_5
	gen own_mat10_`i'0_6 = own_mat5_`i'0_6+own_mat5_`i'5_6
	gen own_mat10_`i'0_0 = own_mat5_`i'0_0+own_mat5_`i'5_0
}

drop own_mat5*

unab selected_ownweather: own_mat10_*  own_rain_* own_snow* own_prec_* 


** get residuals
* sales, wk 0
qui reg sales2 i.week i.year h* if t==0
predict tmp if t==0, res
egen sales2_w0_res = max(tmp), by(opening_sat_date)
drop tmp
	
* sales, other wks
forvalues i=1/5{
	qui reg sales2 i.week i.year h* `selected_ownweather' if t==`i'
	predict tmp if t==`i', res
	egen sales2_w`i'_res = max(tmp), by(opening_sat_date)
	drop tmp
}
gen sales2_wn1_res = sales2_w1_res + sales2_w2_res + sales2_w3_res + sales2_w4_res + sales2_w5_res

* opening weather
unab mor_weather_all_squared: prcp* snow* tmin* tmax* sq_prc* sq_sno* sq_tmin* sq_tmax*
foreach var of varlist `mor_weather_all_squared' {
	qui reg `var' i.week i.year h* if t==0
	predict tmp if t==0, res
	egen `var'_res = max(tmp), by(opening_sat_date)
	drop tmp
}


save moretti_comparison/dta/moretti_data_combined_table_f1_panelB, replace
rm temp/moretti_weather_data_clean.dta
rm temp/moretti_film_data_clean.dta

