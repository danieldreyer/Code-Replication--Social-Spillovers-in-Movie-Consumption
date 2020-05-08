
************
** PREAMBLE
************
* set base directory
*cd "PATH_TO_DIRECTORY"

set more off, permanently
set scheme s1mono
global clus date
set matsize 10000


************
** NATIONAL ANALYSIS
************

* collapse and merge data
do main/do/collapse_merge_national.do

* run Matlab scripts for LASSO results:
* matlab/standard/RUN_LASSO_STANDARD.m

* make figures
do main/do/make_figure_1.do
do main/do/make_figure_2.do
do main/do/make_figure_3.do
do main/do/make_figure_4.do
do main/do/make_figure_5.do
do main/do/make_figure_b2.do
do main/do/make_figure_b4.do

* make tables
do main/do/make_table_1_2_a1.do
do main/do/make_table_3.do
do main/do/make_table_5_a6.do
do main/do/make_table_6.do
do main/do/make_table_7.do
do main/do/make_table_a2.do
do main/do/make_table_a4.do

* table d1 requires truncated movies
do main/do/collapse_merge_national_incl_trunc.do
do main/do/make_table_d1.do

************
** LOCAL ANALYSIS
************

* collapse and merge data
do local/do/collapse_residualize_local.do

* run Matlab scripts for LASSO results:
* matlab/standard/RUN_LASSO_STANDARD_LOCAL.m

* make figures
do local/do/make_figure_6.do
do local/do/make_figure_7.do
do local/do/make_figure_8.do
do local/do/make_figure_b1.do
do local/do/make_figure_b3.do

* make tables
do local/do/make_table_4_a5_a7_rows_2_3.do

* do it with no FE
do local/do/collapse_residualize_local_no_movie_fe.do
* Run: matlab/standard/RUN_LASSO_STANDARD_LOCAL.m
do local/do/make_table_4_a5_a7_row_1.do


************
** COMPARISON WITH MORETTI 2011
************

* make tables
do moretti_comparison/do/make_table_f1_panelA.do

do moretti_comparison/do/merge_data_table_f1_panelB.do
do moretti_comparison/do/make_table_f1_panelB.do

do moretti_comparison/do/merge_data_table_f2.do
do moretti_comparison/do/make_table_f2.do


************
** CLEANUP
************

* remove derived data
do main/do/cleanup.do
do local/do/cleanup.do
do moretti_comparison/do/cleanup.do
rm "tab/*"
