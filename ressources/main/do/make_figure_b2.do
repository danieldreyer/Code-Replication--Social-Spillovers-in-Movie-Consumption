***********
********** BEGIN FIGURE: Uncertainty by Production Budget ***********
***********

use main/dta/films_day.dta, clear
drop if dropped==1

* denominate prod budget in millions
replace production_budget = production_budget / 10^6

* get opening theaters
gen tmp = theaters if wk1==1
egen theaterso = max(tmp), by(id2)
drop tmp

* get non opening wk tickets
gen tmp = tickets if wk1==0
egen tickets_not1 = sum(tmp), by(id2)
drop tmp

* keep only wk1
keep if wk1==1

* collapse over wk1
collapse (sum) tickets (first) tickets_not1 theaterso production_budget opening_sat_date, by(id2)

* how much do production budgets explain?
reg tickets production_budget

* generate variables
gen year=year(opening_sat_date)
gen ln_tickets_not1 = log(tickets_not1)
gen ln_theaterso = log(theaterso)

* get the surprise
reg ln_tickets_not1 ln_theaterso ,r
predict res_surprise, res

label var res_surprise "Surprise"
label var production_budget "Production Budget ({c $|}1,000,000s)"

* plot surprise against production budget
scatter res_surprise production_budget, msize(tiny) title("A. Surprise vs. Production Budget")
gr save "temp/surprise_prod_budget.gph", replace

* get quantiles of production budget
gen p33_highbudget=.
gen p33_lowbudget=.
forval i=2002/2012{
	xtile tmp = production_budget if production_budget!=. & year==`i', nq(3)
	replace p33_highbudget =(tmp==3) if year==`i'
	replace p33_lowbudget =(tmp==1) if year==`i'
	drop tmp
}
gen prodtile = p33_highbudget + 2*p33_lowbudget

* take out means for each quantile
* high
reg res_surprise if p33_highbudget==1
predict res_surprise_h if p33_highbudget==1,res

* low
reg res_surprise if p33_lowbudget==1
predict res_surprise_l if p33_lowbudget==1,res

* density plot
kdensity res_surprise_h if  p33_highbudget==1, ///
	addplot(kdensity res_surprise_l if p33_lowbudget==1) ///
	xtitle("Surprise") legend(label(1 "High Budget") label(2 "Low Budget") rows(1)) ///
	title("B. Kernel Density Comparison") note("") lpattern(dash)
gr save "temp/surprise_prod_budget_terc.gph", replace

graph combine "temp/surprise_prod_budget.gph" ///
	"temp/surprise_prod_budget_terc.gph", ///
	rows(1) xsize(8) altshrink
gr export "graphics/uncertainty.pdf", replace

rm temp/surprise_prod_budget.gph
rm temp/surprise_prod_budget_terc.gph

* non-parametric test
gen res_surprise_both = res_surprise_l
replace res_surprise_both = res_surprise_h if !missing(res_surprise_h)
ksmirnov res_surprise_both, by(prodtile)

* get sd's
sum res_surprise_l res_surprise_h,d
sum res_surprise if p33_lowbudget==0 & p33_highbudget==0 & !missing(production_budget)

***********
********** END FIGURE: Uncertainty by Production Budget ***********
***********

