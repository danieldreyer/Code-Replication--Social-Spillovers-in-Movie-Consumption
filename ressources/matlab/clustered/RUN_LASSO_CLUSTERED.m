% Run IV LASSO program

clear ;
clc ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read in data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in data
names1 = importfile('../data/opening_wkend_clus.csv');

% outcome
y = tickets;
X = tickets;

% fixed effects (note diff notation from old lasso code!)
Dt = [ones(size(y,1)), dow_1, dow_2, dow_3, hhchristmas2023, hhchristmas24, hhchristmas25, hhchristmas2630, hhcinco, hhcolum, hhdayoff, hheaster, hheasterfri, hheastersat, hhhallow, hhjuly4, hhlabor, hhmem, hhmlk, hhmother, hhnewyear1, hhnewyear23, hhnewyear31, hhpres, hhstpat, hhsuperbowl, hhthankthur, hhthankwed, hhthankwkend, hhvalen, hhvet, hhwkdchris, hhwkdchrispost, hhwkdchrispre, hhwkdjul4, hhwkdnewyr, hhwkdnewyrpost, hhwkdother, hhwkdvet, hmcolum, hmjuly4fed, hmlabor, hmmem, hmmlk, hmpres, hp2mcolum, hp2mjuly4fed, hp2mlabor, hp2mmem, hp2mmlk, hp2mpres, hp3mcolum, hp3mjuly4fed, hp3mlabor, hp3mmem, hp3mmlk, hp3mpres, hpcolum, hpjuly4fed, hplabor, hpmem, hpmlk, hppres ...
    ww1, ww10, ww11, ww12, ww13, ww14, ww15, ww16, ww17, ww18, ww19, ww2, ww20, ww21, ww22, ww23, ww24, ww25, ww26, ww27, ww28, ww29, ww3, ww30, ww31, ww32, ww33, ww34, ww35, ww36, ww37, ww38, ww39, ww4, ww40, ww41, ww42, ww43, ww44, ww45, ww46, ww47, ww48, ww49, ww5, ww50, ww51, ww52, ww6, ww7, ww8, ww9, yy1, yy10, yy11, yy2, yy3, yy4, yy5, yy6, yy7, yy8, yy9];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% set up instruments
%%%%% 5 degree increments
z_mat5_fri = [own_mat5_10_5, own_mat5_15_5, own_mat5_20_5, own_mat5_25_5, own_mat5_30_5, ...
    own_mat5_35_5, own_mat5_40_5, own_mat5_45_5, own_mat5_50_5, own_mat5_55_5, own_mat5_60_5, ...
    own_mat5_65_5, own_mat5_70_5, own_mat5_75_5, own_mat5_80_5, own_mat5_85_5, own_mat5_90_5, ...
    own_mat5_95_5];
namez_mat5_fri = {'own_mat5_10_5', 'own_mat5_15_5', 'own_mat5_20_5', 'own_mat5_25_5', 'own_mat5_30_5', ...
    'own_mat5_35_5', 'own_mat5_40_5', 'own_mat5_45_5', 'own_mat5_50_5', ...
    'own_mat5_55_5', 'own_mat5_60_5', 'own_mat5_65_5', 'own_mat5_70_5', ...
    'own_mat5_75_5', 'own_mat5_80_5', 'own_mat5_85_5', 'own_mat5_90_5', ...
    'own_mat5_95_5'};

z_mat5_sat = [own_mat5_10_6, own_mat5_15_6, own_mat5_20_6, own_mat5_25_6, own_mat5_30_6, ...
    own_mat5_35_6, own_mat5_40_6, own_mat5_45_6, own_mat5_50_6, own_mat5_55_6, own_mat5_60_6, ...
    own_mat5_65_6, own_mat5_70_6, own_mat5_75_6, own_mat5_80_6, own_mat5_85_6, own_mat5_90_6, ...
    own_mat5_95_6];
namez_mat5_sat = {'own_mat5_10_6', 'own_mat5_15_6', 'own_mat5_20_6', 'own_mat5_25_6', 'own_mat5_30_6', ...
    'own_mat5_35_6', 'own_mat5_40_6', 'own_mat5_45_6', 'own_mat5_50_6', ...
    'own_mat5_55_6', 'own_mat5_60_6', 'own_mat5_65_6', 'own_mat5_70_6', ...
    'own_mat5_75_6', 'own_mat5_80_6', 'own_mat5_85_6', 'own_mat5_90_6', ...
    'own_mat5_95_6'};

z_mat5_sun = [own_mat5_10_0, own_mat5_15_0, own_mat5_20_0, own_mat5_25_0, own_mat5_30_0, ...
    own_mat5_35_0, own_mat5_40_0, own_mat5_45_0, own_mat5_50_0, own_mat5_55_0, own_mat5_60_0, ...
    own_mat5_65_0, own_mat5_70_0, own_mat5_75_0, own_mat5_80_0, own_mat5_85_0, own_mat5_90_0, ...
    own_mat5_95_0];
namez_mat5_sun = {'own_mat5_10_0', 'own_mat5_15_0', 'own_mat5_20_0', 'own_mat5_25_0', 'own_mat5_30_0', ...
    'own_mat5_35_0', 'own_mat5_40_0', 'own_mat5_45_0', 'own_mat5_50_0', ...
    'own_mat5_55_0', 'own_mat5_60_0', 'own_mat5_65_0', 'own_mat5_70_0', ...
    'own_mat5_75_0', 'own_mat5_80_0', 'own_mat5_85_0', 'own_mat5_90_0', ...
    'own_mat5_95_0'};

%%%%% 10 degree increments
z_mat10_fri = [own_mat10_10_5, own_mat10_20_5, own_mat10_30_5, own_mat10_40_5, ...
    own_mat10_50_5, own_mat10_60_5, own_mat10_70_5, own_mat10_80_5, own_mat10_90_5];
namez_mat10_fri = {'own_mat10_10_5', 'own_mat10_20_5', 'own_mat10_30_5', 'own_mat10_40_5', ...
    'own_mat10_50_5', 'own_mat10_60_5', 'own_mat10_70_5', 'own_mat10_80_5', 'own_mat10_90_5'};

z_mat10_sat = [own_mat10_10_6, own_mat10_20_6, own_mat10_30_6, own_mat10_40_6, ...
    own_mat10_50_6, own_mat10_60_6, own_mat10_70_6, own_mat10_80_6, own_mat10_90_6];
namez_mat10_sat = {'own_mat10_10_6', 'own_mat10_20_6', 'own_mat10_30_6', 'own_mat10_40_6', ...
    'own_mat10_50_6', 'own_mat10_60_6', 'own_mat10_70_6', 'own_mat10_80_6', 'own_mat10_90_6'};

z_mat10_sun = [own_mat10_10_0, own_mat10_20_0, own_mat10_30_0, own_mat10_40_0, ...
    own_mat10_50_0, own_mat10_60_0, own_mat10_70_0, own_mat10_80_0, own_mat10_90_0];
namez_mat10_sun = {'own_mat10_10_0', 'own_mat10_20_0', 'own_mat10_30_0', 'own_mat10_40_0', ...
    'own_mat10_50_0', 'own_mat10_60_0', 'own_mat10_70_0', 'own_mat10_80_0', 'own_mat10_90_0'};


%%%%% rain, prec, snow for sat/sun
z_rain = [own_rain_6 own_rain_0];
namez_rain = {'own_rain_6' 'own_rain_0'};

z_snow = [own_snow_6 own_snow_0];
namez_snow = {'own_snow_6' 'own_snow_0'};

z_prec_sat = [own_prec_0_6, own_prec_1_6, own_prec_2_6, ...
    own_prec_3_6, own_prec_4_6, own_prec_5_6];
namez_prec_sat = {'own_prec_0_6', 'own_prec_1_6', 'own_prec_2_6',...
    'own_prec_3_6', 'own_prec_4_6', 'own_prec_5_6'};

z_prec_sun = [own_prec_0_0, own_prec_1_0, own_prec_2_0, ...
    own_prec_3_0, own_prec_4_0, own_prec_5_0];
namez_prec_sun = {'own_prec_0_0', 'own_prec_1_0', 'own_prec_2_0',...
    'own_prec_3_0', 'own_prec_4_0', 'own_prec_5_0'};

%%%%% put all together
z = 1*[z_mat5_sat z_mat5_sun z_rain z_snow z_prec_sat z_prec_sun];
namez = [namez_mat5_sat namez_mat5_sun namez_rain namez_snow namez_prec_sat namez_prec_sun];

d = z;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Instrument selection after partialing out FE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% set up fixed effects XXXX
%group = kron((1:n)',ones(T,1));
group = opening_wkend_group; % use opening_wkend_group if want to cluster by opening wkend


% data parameters
N = size(y,1);
T = 3; % 3 if grouping by opening weekend, otherwise 1
n = N/T;
p = ceil((T-(-2))*n);

% lasso penalty parameters
levelH = .1/log(N);
levelC = .1/log(n);
lambdaH = 2.2*sqrt(N)*norminv(1-levelH/(2*p));
lambdaC = 2.2*sqrt(n)*norminv(1-levelC/(2*p));


% Partial out FE
Xp = X - Dt*(Dt\X);
Yp = y - Dt*(Dt\y);
Dp = d - Dt*(Dt\d);


% Heteroskedastic penalty loadings
ssD = feasiblePostLasso(Xp,Dp,'lambda',lambdaH);
use = logical(abs(ssD) > 0);
name_hetero = namez(use)

% Clustered penalty loadings
ssD = feasiblePostLasso(Xp,Dp,'lambda',lambdaC,'clusterVar',group);
use = logical(abs(ssD) > 0);
name_cluster = namez(use)


