** NOTE: THIS IS MORETTI 2011'S CODE

*******************************************
*******************************************
* WEATHER
*******************************************
*******************************************
u  moretti_comparison/dta/moretti_weather_data, replace
g date = mdy(month,day,year)
drop if date ==.
save  temp/tmp, replace

u   moretti_comparison/dta/moretti_weather_data
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
save  temp/tmp2, replace

* merge
u  temp/tmp
sort date
merge date using  temp/tmp2
keep if _merge==3
drop _merge
rename date opening_date
sort opening_date
save  temp/tmp3, replace
rm  temp/tmp.dta
rm  temp/tmp2.dta


*******************************************************
*******************************************************

clear
u   moretti_comparison/dta/moretti_film_data

*******************************************
*******************************************
* NEW VARIABLES
*******************************************
*******************************************
replace lenght = 100 if lenght ==.
egen mean_cost = mean(cost)
g cost_imputed = (cost ==.)
replace cost = mean_cost if cost ==. 
drop mean_cost

* All dollar variables are in 2005 dollars
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
summ dd , detai
egen max = max(dd), by(id)
g open_ny_la = (max>5)
drop max

* identifiers for possible typos in sales
g ratio = sales2/sales
egen max = max(ratio), by(id)
g typo = 1 if max >3 & max ~=.
drop max ratio

* identifiers for movies that might have sold out the first week
* They are movies where sales per screen are in the top 5%
g ratio = sales_first_weekend/screens_first_week
xtile Q_ratio = ratio,  nquantiles(100)
g       sold_out = (Q_ratio >95)
replace sold_out = . if Q_ratio ==.
drop ratio Q_ratio


*******************************************
*******************************************
* DEFINE SALES
* Alternative: weekly sales (sales) 
*              instead of week-end sales (sales2)
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


* drop if first week-end is sold out
* drop if sold_out            ==1


* drop if cost_imputed      ==1
* If the line below is activated, then 5175 needs to become 3740 in the distribution of slopes part
* keep if screens_first_week  >3
* The following line keeps only films that have positive sales in all the 8 weeks 
* keep if non_zero2 ==8


*****************************************
*****************************************
* WEATHER
*****************************************
*****************************************
summ


* MERGE
sort opening_date
merge opening_date using  temp/tmp3
tab _merge
drop _merge
rm  temp/tmp3.dta
keep if y0 ~=.

summ

*******************************************
*******************************************
* DEFINE SURPRISE IN FIRST WEEK-END SALES
*******************************************
*******************************************
xi: regress y0 screens0 if t ==0

predict predicted_sales if e(sample)
correlate y0 predicted_sales 
g    diff     = y0 - predicted        
g e_diff      = exp(diff)-1
summ diff e_diff, detail
egen surprise = max(diff), by(id)
drop diff



*******************************************
* SQUARED WEATHER
*******************************************
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




****************
* INTERACTION OF TIME AND SURPRISE
***************
g pos_surp = (surprise>=0)
g neg_surp = (surprise<0)
g t_surprise = t*surprise
g t_pos_surp = t*(surprise>=0)
g t_neg_surp = t*(surprise<0)
g t_sq = t*t
g t_sq_pos_surp = t_sq*(surprise>=0)
xtile Q_surprise = surprise,  nquantiles(3)
g t_Q1 = t*(Q==1)
g t_Q2 = t*(Q==2)
g t_Q3 = t*(Q==3)
g t2_Q1 = t*t*(Q==1)
g t2_Q2 = t*t*(Q==2)
g t2_Q3 = t*t*(Q==3)


***************************

g t_prcp8031    = t*    prcp8031
g t_prcp8031_1  = t*    prcp8031_1
g t_prcp17031   = t*    prcp17031
g t_prcp17031_1 = t*    prcp17031_1
g t_prcp20209   = t*    prcp20209
g t_prcp20209_1 = t*    prcp20209_1
g t_prcp25025  = t*    prcp25025
g t_prcp25025_1 = t*    prcp25025_1
g t_prcp26163   = t*    prcp26163
g t_prcp26163_1 = t*    prcp26163_1
g t_prcp36061   = t*    prcp36061
g t_prcp36061_1 = t*    prcp36061_1
g t_snow8031   = t*    snow8031
g t_snow8031_1  = t*    snow8031_1
g t_snow17031   = t*    snow17031
g t_snow17031_1 = t*    snow17031_1
g t_snow20209   = t*    snow20209
g t_snow20209_1 = t*    snow20209_1
g t_snow25025   = t*    snow25025
g t_snow25025_1 = t*    snow25025_1
g t_snow26163   = t*    snow26163
g t_snow26163_1 = t*    snow26163_1
g t_snow36061   = t*    snow36061
g t_snow36061_1 = t*    snow36061_1
g t_tmin8031    = t*    tmin8031
g t_tmin8031_1  = t*    tmin8031_1
g t_tmin17031   = t*    tmin17031
g t_tmin17031_1 = t*    tmin17031_1
g t_tmin20209   = t*    tmin20209
g t_tmin20209_1= t*    tmin20209_1
g t_tmin25025  = t*    tmin25025
g t_tmin25025_1 = t*    tmin25025_1
g t_tmin26163   = t*    tmin26163
g t_tmin26163_1 = t*    tmin26163_1
g t_tmin36061   = t*    tmin36061
g t_tmin36061_1 = t*    tmin36061_1
g t_tmax8031    = t*    tmax8031
g t_tmax8031_1  = t*    tmax8031_1
g t_tmax17031   = t*    tmax17031
g t_tmax17031_1 = t*    tmax17031_1
g t_tmax20209   = t*    tmax20209
g t_tmax20209_1 = t*    tmax20209_1
g t_tmax25025   = t*    tmax25025
g t_tmax25025_1 = t*    tmax25025_1
g t_tmax26163   = t*    tmax26163
g t_tmax26163_1 = t*    tmax26163_1
g t_tmax36061   = t*    tmax36061
g t_tmax36061_1 = t*    tmax36061_1

g t_sq_prcp8031    = t*    sq_prcp8031
g t_sq_prcp8031_1  = t*    sq_prcp8031_1
g t_sq_prcp17031   = t*    sq_prcp17031
g t_sq_prcp17031_1 = t*    sq_prcp17031_1
g t_sq_prcp20209   = t*    sq_prcp20209
g t_sq_prcp20209_1 = t*    sq_prcp20209_1
g t_sq_prcp25025  = t*    sq_prcp25025
g t_sq_prcp25025_1 = t*    sq_prcp25025_1
g t_sq_prcp26163   = t*    sq_prcp26163
g t_sq_prcp26163_1 = t*    sq_prcp26163_1
g t_sq_prcp36061   = t*    sq_prcp36061
g t_sq_prcp36061_1 = t*    sq_prcp36061_1
g t_sq_snow8031   = t*    sq_snow8031
g t_sq_snow8031_1  = t*    sq_snow8031_1
g t_sq_snow17031   = t*    sq_snow17031
g t_sq_snow17031_1 = t*    sq_snow17031_1
g t_sq_snow20209   = t*    sq_snow20209
g t_sq_snow20209_1 = t*    sq_snow20209_1
g t_sq_snow25025   = t*    sq_snow25025
g t_sq_snow25025_1 = t*    sq_snow25025_1
g t_sq_snow26163   = t*    sq_snow26163
g t_sq_snow26163_1 = t*    sq_snow26163_1
g t_sq_snow36061   = t*    sq_snow36061
g t_sq_snow36061_1 = t*    sq_snow36061_1
g t_sq_tmin8031    = t*    sq_tmin8031
g t_sq_tmin8031_1  = t*    sq_tmin8031_1
g t_sq_tmin17031   = t*    sq_tmin17031
g t_sq_tmin17031_1 = t*    sq_tmin17031_1
g t_sq_tmin20209   = t*    sq_tmin20209
g t_sq_tmin20209_1= t*    sq_tmin20209_1
g t_sq_tmin25025  = t*    sq_tmin25025
g t_sq_tmin25025_1 = t*    sq_tmin25025_1
g t_sq_tmin26163   = t*    sq_tmin26163
g t_sq_tmin26163_1 = t*    sq_tmin26163_1
g t_sq_tmin36061   = t*    sq_tmin36061
g t_sq_tmin36061_1 = t*    sq_tmin36061_1
g t_sq_tmax8031    = t*    sq_tmax8031
g t_sq_tmax8031_1  = t*    sq_tmax8031_1
g t_sq_tmax17031   = t*    sq_tmax17031
g t_sq_tmax17031_1 = t*    sq_tmax17031_1
g t_sq_tmax20209   = t*    sq_tmax20209
g t_sq_tmax20209_1 = t*    sq_tmax20209_1
g t_sq_tmax25025   = t*    sq_tmax25025
g t_sq_tmax25025_1 = t*    sq_tmax25025_1
g t_sq_tmax26163   = t*    sq_tmax26163
g t_sq_tmax26163_1 = t*    sq_tmax26163_1
g t_sq_tmax36061   = t*    sq_tmax36061
g t_sq_tmax36061_1 = t*    sq_tmax36061_1

label var sales "week sales"
label var sales2 "weekend sales"

save moretti_comparison/dta/moretti_data_combined_table_f2, replace
