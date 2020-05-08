
use moretti_comparison/dta/moretti_data_combined_table_f2, replace

**** get opening sat date
gen dow = dow(opening_date)
gen opening_sat_date = opening_date + 6 - dow
drop dow

**** add year and week FE
drop week year
gen sat_date = opening_sat_date + 7*t
gen week = week(sat_date)
gen year = year(sat_date)
qui tab week, gen(w_)
qui tab year, gen(y_)


**** add holidays
merge m:1 sat_date using moretti_comparison/dta/holidays_week.dta
drop if _merge == 2
drop _merge


**** do t interaction
gen tweek = week*10 + t
qui tab tweek, gen(tw_)
gen tyear = year*10 + t
qui tab tyear, gen(ty_)

foreach var of varlist h*{
	forvalues i=0/7{
		gen t`var'`i' = (t==`i')*`var'
	}
}


forvalues i = 0/7{
	gen surprise_t`i' = surprise
}


*******************************************
*******************************************
* RUN MORETTI'S REGRESSIONS
*******************************************
*******************************************
* OLS
reg y  surprise t_surprise t, cluster(id) 

reg y  surprise t_surprise t if tmin8031 ~=. & tmin17031 ~=. & tmin20209 ~=. & tmin25025 ~=. & tmin26163 ~=. & tmin36061 & tmin8031_1 ~=. & tmin17031_1 ~=. & tmin20209_1 ~=. & tmin25025_1 ~=. & tmin26163_1 ~=. & tmin36061_1 & tmax8031 ~=. & tmax17031 ~=. & tmax20209 ~=. & tmax25025 ~=. & tmax26163 ~=. & tmax36061 & tmax8031_1 ~=. & tmax17031_1 ~=. & tmax20209_1 ~=. & tmax25025_1 ~=. & tmax26163_1 ~=. & tmax36061_1 , cluster(id)
outreg2 t_surprise using tab/moretti_true.xls, replace

* IV - NO SQUARED WEATHER
ivreg2 y  (surprise t_surprise =             tmin* tmax*                 t_tmin* t_tmax*) t, cluster(id) first
outreg2 t_surprise using tab/moretti_true.xls, append addstat("f-stat", e(widstat))

ivreg2 y  (surprise t_surprise = prcp* snow* tmin* tmax* t_prcp* t_snow* t_tmin* t_tmax*) t, cluster(id) 
outreg2 t_surprise using tab/moretti_true.xls, append addstat("f-stat", e(widstat))


* IV - SQUARED WEATHER
ivreg2 y  (surprise t_surprise =             tmin* tmax*                 t_tmin* t_tmax* sq_tmin* sq_tmax* t_sq_tmin* t_sq_tmax*) t, cluster(id) 
outreg2 t_surprise using tab/moretti_true.xls, append addstat("f-stat", e(widstat))

ivreg2 y  (surprise t_surprise = prcp* snow* tmin* tmax* t_prcp* t_snow* t_tmin* t_tmax* sq_prc* sq_sno* sq_tmin* sq_tmax* t_sq_prc* t_sq_sno* t_sq_tmin* t_sq_tmax*) t, cluster(id) first
outreg2 t_surprise using tab/moretti_true.xls, append addstat("f-stat", e(widstat))


********************************
* OLS
reg y  pos_surp t_pos_surp t, cluster(id) 

reg y  pos_surp t_pos_surp t if tmin8031 ~=. & tmin17031 ~=. & tmin20209 ~=. & tmin25025 ~=. & tmin26163 ~=. & tmin36061 & tmin8031_1 ~=. & tmin17031_1 ~=. & tmin20209_1 ~=. & tmin25025_1 ~=. & tmin26163_1 ~=. & tmin36061_1 & tmax8031 ~=. & tmax17031 ~=. & tmax20209 ~=. & tmax25025 ~=. & tmax26163 ~=. & tmax36061 & tmax8031_1 ~=. & tmax17031_1 ~=. & tmax20209_1 ~=. & tmax25025_1 ~=. & tmax26163_1 ~=. & tmax36061_1, cluster(id)
outreg2 t_pos_surp using tab/moretti_true.xls, append

* IV - NO SQUARED WEATHER
ivreg2 y  (pos_surp t_pos_surp =             tmin* tmax*                 t_tmin* t_tmax*) t, cluster(id) 
outreg2 t_pos_surp using tab/moretti_true.xls, append addstat("f-stat", e(widstat))

ivreg2 y  (pos_surp t_pos_surp = prcp* snow* tmin* tmax* t_prcp* t_snow* t_tmin* t_tmax*) t, cluster(id) 
outreg2 t_pos_surp using tab/moretti_true.xls, append addstat("f-stat", e(widstat))

* IV - SQUARED WEATHER
ivreg2 y  (pos_surp t_pos_surp =             tmin* tmax*                 t_tmin* t_tmax* sq_tmin* sq_tmax* t_sq_tmin* t_sq_tmax*) t, cluster(id) 
outreg2 t_pos_surp using tab/moretti_true.xls, append addstat("f-stat", e(widstat))

ivreg2 y  (pos_surp t_pos_surp = prcp* snow* tmin* tmax* t_prcp* t_snow* t_tmin* t_tmax* sq_prc* sq_sno* sq_tmin* sq_tmax* t_sq_prc* t_sq_sno* t_sq_tmin* t_sq_tmax*) t, cluster(id) 
outreg2 t_pos_surp using tab/moretti_true.xls, append addstat("f-stat", e(widstat))



*******************************************
*******************************************
** REPEAT MORETTI'S REGRESSIONS WITH SEASONAL CONTROLS
*******************************************
*******************************************

* OLS
reg y w_* y_* h* surprise t_surprise t, cluster(id) 

reg y tw_* ty_* th* surprise t_surprise t if tmin8031 ~=. & tmin17031 ~=. & tmin20209 ~=. & tmin25025 ~=. & tmin26163 ~=. & tmin36061 & tmin8031_1 ~=. & tmin17031_1 ~=. & tmin20209_1 ~=. & tmin25025_1 ~=. & tmin26163_1 ~=. & tmin36061_1 & tmax8031 ~=. & tmax17031 ~=. & tmax20209 ~=. & tmax25025 ~=. & tmax26163 ~=. & tmax36061 & tmax8031_1 ~=. & tmax17031_1 ~=. & tmax20209_1 ~=. & tmax25025_1 ~=. & tmax26163_1 ~=. & tmax36061_1 , cluster(id)
outreg2 t_surprise using tab/moretti_true_fe.xls, replace

* IV - NO SQUARED WEATHER
ivreg2 y tw_* ty_* th* (surprise t_surprise =             tmin* tmax*                 t_tmin* t_tmax*) t, cluster(id)
outreg2 t_surprise using tab/moretti_true_fe.xls, append

ivreg2 y tw_* ty_* th* (surprise t_surprise = prcp* snow* tmin* tmax* t_prcp* t_snow* t_tmin* t_tmax*) t, cluster(id) 
outreg2 t_surprise using tab/moretti_true_fe.xls, append


* IV - SQUARED WEATHER
ivreg2 y tw_* ty_* th* (surprise t_surprise =             tmin* tmax*                 t_tmin* t_tmax* sq_tmin* sq_tmax* t_sq_tmin* t_sq_tmax*) t, cluster(id) 
outreg2 t_surprise using tab/moretti_true_fe.xls, append 

ivreg2 y tw_* ty_* th* (surprise t_surprise = prcp* snow* tmin* tmax* t_prcp* t_snow* t_tmin* t_tmax* sq_prc* sq_sno* sq_tmin* sq_tmax* t_sq_prc* t_sq_sno* t_sq_tmin* t_sq_tmax*) t, cluster(id) 
outreg2 t_surprise using tab/moretti_true_fe.xls, append 


********************************

* OLS
reg y tw_* ty_* th* pos_surp t_pos_surp t if tmin8031 ~=. & tmin17031 ~=. & tmin20209 ~=. & tmin25025 ~=. & tmin26163 ~=. & tmin36061 & tmin8031_1 ~=. & tmin17031_1 ~=. & tmin20209_1 ~=. & tmin25025_1 ~=. & tmin26163_1 ~=. & tmin36061_1 & tmax8031 ~=. & tmax17031 ~=. & tmax20209 ~=. & tmax25025 ~=. & tmax26163 ~=. & tmax36061 & tmax8031_1 ~=. & tmax17031_1 ~=. & tmax20209_1 ~=. & tmax25025_1 ~=. & tmax26163_1 ~=. & tmax36061_1, cluster(id)
outreg2 t_pos_surp using tab/moretti_true_fe.xls, append

* IV - NO SQUARED WEATHER
ivreg2 y tw_* ty_* th* (pos_surp t_pos_surp =             tmin* tmax*                 t_tmin* t_tmax*) t, cluster(id) 
outreg2 t_pos_surp using tab/moretti_true_fe.xls, append 

ivreg2 y tw_* ty_* th* (pos_surp t_pos_surp = prcp* snow* tmin* tmax* t_prcp* t_snow* t_tmin* t_tmax*) t, cluster(id) 
outreg2 t_pos_surp using tab/moretti_true_fe.xls, append 

* IV - SQUARED WEATHER
ivreg2 y tw_* ty_* th* (pos_surp t_pos_surp =             tmin* tmax*                 t_tmin* t_tmax* sq_tmin* sq_tmax* t_sq_tmin* t_sq_tmax*) t, cluster(id) 
outreg2 t_pos_surp using tab/moretti_true_fe.xls, append 

ivreg2 y tw_* ty_* th* (pos_surp t_pos_surp = prcp* snow* tmin* tmax* t_prcp* t_snow* t_tmin* t_tmax* sq_prc* sq_sno* sq_tmin* sq_tmax* t_sq_prc* t_sq_sno* t_sq_tmin* t_sq_tmax*) t, cluster(id) 
outreg2 t_pos_surp using tab/moretti_true_fe.xls, append
	
