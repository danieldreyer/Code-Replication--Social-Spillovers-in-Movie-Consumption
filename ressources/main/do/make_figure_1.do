***********
********** BEGIN Figure 1: Average Audience Sizes by Week in Theater ***********
***********
* for each movie
use main/dta/films_day.dta, replace

egen wktick=mean(tickets), by(id2 wkintheaters)
egen wktheaters=mean(theaters), by(id2 wkintheaters)
gen wktickth = 1000000*wktick/wktheaters

collapse (mean) wktick wktheaters wktickth, by(wkintheaters)

twoway (connected wktick wkintheaters, title("A. by Movie") xtitle("Week in Theaters") ytitle("Average Daily Audience (1,000,000s)", axis(1)) yaxis(1)) (connected wktickth wkintheaters, ytitle("Average Daily Audience per Screen", axis(2)) lpattern(dash) msymbol(T) yaxis(2) legend(label(1 "Audience") label(2 "Audience per Screen")) legend(stack))
gr save "temp/uncollapsed.gph", replace

* then make it for each week
use main/dta/films_day.dta, replace
collapse (sum) tickets theaters (mean) dow wk1 wk2 wk3 wk4 wk5 wk6 wkintheaters, by(opening_sat_date date)

egen wktick=mean(tickets), by(wkintheaters)
egen wktheaters=mean(theaters), by(wkintheaters)
gen wktickth = 1000000*wktick/wktheaters

collapse (mean) wktick wktheaters wktickth, by(wkintheaters)

twoway (connected wktick wkintheaters, title("B. by Weekend Released") xtitle("Week in Theaters") ytitle("Average Daily Audience (1,000,000s)", axis(1)) yaxis(1)) (connected wktickth wkintheaters, ytitle("Average Daily Audience per Screen", axis(2)) lpattern(dash) msymbol(T) yaxis(2) legend(label(1 "Audience") label(2 "Audience per Screen")) legend(stack))
gr save "temp/collapsed.gph", replace

* combine
graph combine "temp/uncollapsed.gph" "temp/collapsed.gph", altshrink xsize(8)
gr export "graphics/audiences.pdf", replace

rm temp/uncollapsed.gph
rm temp/collapsed.gph
***********
********** END Figure 1 ***********
***********
