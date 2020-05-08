* BEGIN FIGURE:
* Local First Stage Binscatters

use  "local/dta/local_searches_weather_resid", replace

**** FIRST STAGE BINSCATTER BY CITY
local weathervar z_open_mat5_85_res_6

** NYC only
* take out weeek minus 1 searches
reg z_searches_res z_searches_res_rwm1 if week_num==0 & id_msa==1
predict tmp_res_searches, res
reg `weathervar' z_searches_res_rwm1 if week_num==0 & id_msa==1
predict tmp_res_weather, res

* binscatter
reg tmp_res_searches tmp_res_weather if week_num==0 & id_msa==1, r cluster(date)
binscatter tmp_res_searches tmp_res_weather if week_num==0 & id_msa==1, xtitle("") ytitle("") title("A. New York City") ///
	text(.1 3 "Coef: -0.0130" "SE: 0.0179", place(sw)) ///
	color(black) mcolors(black) lcolors(black) graphregion(color(white)) bgcolor(white)
graph save "temp/ff_bs_1.gph", replace
drop tmp*

** LA only
* take out weeek minus 1 searches
local weathervar z_open_mat5_85_res_6
reg z_searches_res z_searches_res_rwm1 if week_num==0 & id_msa==2
predict tmp_res_searches, res
reg `weathervar' z_searches_res_rwm1 if week_num==0 & id_msa==2
predict tmp_res_weather, res

* binscatter
reg tmp_res_searches tmp_res_weather if week_num==0 & id_msa==2, r cluster(date)
binscatter tmp_res_searches tmp_res_weather if week_num==0 & id_msa==2, xtitle("") ytitle("") title("B. Los Angeles") ///
	text(.1 3 "Coef: -0.0241" "SE: 0.0161", place(sw)) ///
	color(black) mcolors(black) lcolors(black) graphregion(color(white)) bgcolor(white)
graph save "temp/ff_bs_2.gph", replace
drop tmp*

** ALL
* take out weeek minus 1 searches
local weathervar z_open_mat5_85_res_6
reg z_searches_res z_searches_res_rwm1 if week_num==0
predict tmp_res_searches, res
reg `weathervar' z_searches_res_rwm1 if week_num==0
predict tmp_res_weather, res

* binscatter
reg tmp_res_searches tmp_res_weather if week_num==0, r cluster(date)
binscatter tmp_res_searches tmp_res_weather if week_num==0, xtitle("") ytitle("") title("C. All") ///
	text(.1 3 "Coef: -0.0292" "SE: 0.008", place(sw)) ///
	color(black) mcolors(black) lcolors(black) graphregion(color(white)) bgcolor(white)
graph save "temp/ff_bs_all.gph", replace
drop tmp*


* combine the graphs
graph combine "temp/ff_bs_1.gph" ///
	"temp/ff_bs_2.gph" ///
	"temp/ff_bs_all.gph" ///
	, b1title("Residual Indicator for Temperature 85-90 Deg F on Opening Weekend (Z-score)") l1title("Residual Local Opening Daily Searches (Z-score)") rows(1) xsize(10) altshrink ycommon
graph export "graphics/firstbinlocal.pdf", replace

rm temp/ff_bs_1.gph
rm temp/ff_bs_2.gph
rm temp/ff_bs_all.gph
