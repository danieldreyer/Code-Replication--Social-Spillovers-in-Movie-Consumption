% Run IV LASSO program

clear ;
clc ;

c = 1.1; % LASSO penalty multiplier

%% Read in data.

% opening wkend
names1 = importfile('../data/opening_wkend.csv');


% base case
d = tickets_wk1d_r; % endogenous variable

% set up matrix of different cuts of tickets
D = tickets_wk1d_r;

D = [D, tickets_ratedgpg_wk1d_r];
D = [D, tickets_adult_wk1d_r];

D = [D, tickets_p33_highbudget_wk1d_r];
D = [D, tickets_p33_lowbudget_wk1d_r];

D = [D, tickets_p33_hr1000_wk1d_r];
D = [D, tickets_p33_lr1000_wk1d_r];

D = [D, tickets_pt_wk1d_r];
D = [D, tickets_pot_wk1d_r];

nameD = {'tickets_wk1d_r', ...
    'tickets_ratedgpg_wk1d_r','tickets_adult_wk1d_r', ...
    'tickets_p33_highbudget_wk1d_r', 'tickets_p33_lowbudget_wk1d_r', ...
    'tickets_p33_hr1000_wk1d_r', 'tickets_p33_lr1000_wk1d_r', ...
    'tickets_pt_wk1d_r','tickets_pot_wk1d_r'};

for d_ind = 1 : size(D,2)

    d = D(:,d_ind);

    days_to_keep = (isnan(d)==0);
    d = d(days_to_keep);

    fprintf('\nLHS is: %s\n', nameD{d_ind})
    fprintf('Num obs is: %d\n\n', size(d,1))

    % use residualized tickets
    x = ones(size(d,1),1); % exogenous controls

    % Candidate instruments, z:
    %%%%% 5 degree increments
    z_mat5_fri = [res_own_mat5_10_5, res_own_mat5_15_5, res_own_mat5_20_5, res_own_mat5_25_5, res_own_mat5_30_5, ...
        res_own_mat5_35_5, res_own_mat5_40_5, res_own_mat5_45_5, res_own_mat5_50_5, res_own_mat5_55_5, res_own_mat5_60_5, ...
        res_own_mat5_65_5, res_own_mat5_70_5, res_own_mat5_75_5, res_own_mat5_80_5, res_own_mat5_85_5, res_own_mat5_90_5, ...
        res_own_mat5_95_5];
    namez_mat5_fri = {'res_own_mat5_10_5', 'res_own_mat5_15_5', 'res_own_mat5_20_5', 'res_own_mat5_25_5', 'res_own_mat5_30_5', ...
        'res_own_mat5_35_5', 'res_own_mat5_40_5', 'res_own_mat5_45_5', 'res_own_mat5_50_5', ...
        'res_own_mat5_55_5', 'res_own_mat5_60_5', 'res_own_mat5_65_5', 'res_own_mat5_70_5', ...
        'res_own_mat5_75_5', 'res_own_mat5_80_5', 'res_own_mat5_85_5', 'res_own_mat5_90_5', ...
        'res_own_mat5_95_5'};

    z_mat5_sat = [res_own_mat5_10_6, res_own_mat5_15_6, res_own_mat5_20_6, res_own_mat5_25_6, res_own_mat5_30_6, ...
        res_own_mat5_35_6, res_own_mat5_40_6, res_own_mat5_45_6, res_own_mat5_50_6, res_own_mat5_55_6, res_own_mat5_60_6, ...
        res_own_mat5_65_6, res_own_mat5_70_6, res_own_mat5_75_6, res_own_mat5_80_6, res_own_mat5_85_6, res_own_mat5_90_6, ...
        res_own_mat5_95_6];
    namez_mat5_sat = {'res_own_mat5_10_6', 'res_own_mat5_15_6', 'res_own_mat5_20_6', 'res_own_mat5_25_6', 'res_own_mat5_30_6', ...
        'res_own_mat5_35_6', 'res_own_mat5_40_6', 'res_own_mat5_45_6', 'res_own_mat5_50_6', ...
        'res_own_mat5_55_6', 'res_own_mat5_60_6', 'res_own_mat5_65_6', 'res_own_mat5_70_6', ...
        'res_own_mat5_75_6', 'res_own_mat5_80_6', 'res_own_mat5_85_6', 'res_own_mat5_90_6', ...
        'res_own_mat5_95_6'};

    z_mat5_sun = [res_own_mat5_10_0, res_own_mat5_15_0, res_own_mat5_20_0, res_own_mat5_25_0, res_own_mat5_30_0, ...
        res_own_mat5_35_0, res_own_mat5_40_0, res_own_mat5_45_0, res_own_mat5_50_0, res_own_mat5_55_0, res_own_mat5_60_0, ...
        res_own_mat5_65_0, res_own_mat5_70_0, res_own_mat5_75_0, res_own_mat5_80_0, res_own_mat5_85_0, res_own_mat5_90_0, ...
        res_own_mat5_95_0];
    namez_mat5_sun = {'res_own_mat5_10_0', 'res_own_mat5_15_0', 'res_own_mat5_20_0', 'res_own_mat5_25_0', 'res_own_mat5_30_0', ...
        'res_own_mat5_35_0', 'res_own_mat5_40_0', 'res_own_mat5_45_0', 'res_own_mat5_50_0', ...
        'res_own_mat5_55_0', 'res_own_mat5_60_0', 'res_own_mat5_65_0', 'res_own_mat5_70_0', ...
        'res_own_mat5_75_0', 'res_own_mat5_80_0', 'res_own_mat5_85_0', 'res_own_mat5_90_0', ...
        'res_own_mat5_95_0'};

    %%%%% 10 degree increments
    z_mat10_fri = [res_own_mat10_10_5, res_own_mat10_20_5, res_own_mat10_30_5, res_own_mat10_40_5, ...
        res_own_mat10_50_5, res_own_mat10_60_5, res_own_mat10_70_5, res_own_mat10_80_5, res_own_mat10_90_5];
    namez_mat10_fri = {'res_own_mat10_10_5', 'res_own_mat10_20_5', 'res_own_mat10_30_5', 'res_own_mat10_40_5', ...
        'res_own_mat10_50_5', 'res_own_mat10_60_5', 'res_own_mat10_70_5', 'res_own_mat10_80_5', 'res_own_mat10_90_5'};

    z_mat10_sat = [res_own_mat10_10_6, res_own_mat10_20_6, res_own_mat10_30_6, res_own_mat10_40_6, ...
        res_own_mat10_50_6, res_own_mat10_60_6, res_own_mat10_70_6, res_own_mat10_80_6, res_own_mat10_90_6];
    namez_mat10_sat = {'res_own_mat10_10_6', 'res_own_mat10_20_6', 'res_own_mat10_30_6', 'res_own_mat10_40_6', ...
        'res_own_mat10_50_6', 'res_own_mat10_60_6', 'res_own_mat10_70_6', 'res_own_mat10_80_6', 'res_own_mat10_90_6'};

    z_mat10_sun = [res_own_mat10_10_0, res_own_mat10_20_0, res_own_mat10_30_0, res_own_mat10_40_0, ...
        res_own_mat10_50_0, res_own_mat10_60_0, res_own_mat10_70_0, res_own_mat10_80_0, res_own_mat10_90_0];
    namez_mat10_sun = {'res_own_mat10_10_0', 'res_own_mat10_20_0', 'res_own_mat10_30_0', 'res_own_mat10_40_0', ...
        'res_own_mat10_50_0', 'res_own_mat10_60_0', 'res_own_mat10_70_0', 'res_own_mat10_80_0', 'res_own_mat10_90_0'};


    %%%%% rain, prec, snow for sat/sun
    z_rain = [res_own_rain_6 res_own_rain_0];
    namez_rain = {'res_own_rain_6' 'res_own_rain_0'};

    z_snow = [res_own_snow_6 res_own_snow_0];
    namez_snow = {'res_own_snow_6' 'res_own_snow_0'};

    z_prec_sat = [res_own_prec_0_6, res_own_prec_1_6, res_own_prec_2_6, ...
        res_own_prec_3_6, res_own_prec_4_6, res_own_prec_5_6];
    namez_prec_sat = {'res_own_prec_0_6', 'res_own_prec_1_6', 'res_own_prec_2_6',...
        'res_own_prec_3_6', 'res_own_prec_4_6', 'res_own_prec_5_6'};

    z_prec_sun = [res_own_prec_0_0, res_own_prec_1_0, res_own_prec_2_0, ...
        res_own_prec_3_0, res_own_prec_4_0, res_own_prec_5_0];
    namez_prec_sun = {'res_own_prec_0_0', 'res_own_prec_1_0', 'res_own_prec_2_0',...
        'res_own_prec_3_0', 'res_own_prec_4_0', 'res_own_prec_5_0'};


    %%%%% set the instruments to LASSO

    % 5 deg incr for sat, sun and prec and snow and rain
    z = 1*[z_mat5_sat z_mat5_sun z_rain z_snow z_prec_sat z_prec_sun];
    namez = [namez_mat5_sat namez_mat5_sun namez_rain namez_snow namez_prec_sat namez_prec_sun];

    % 10 deg incr for sat, sun and prec and snow and rain
    % z = 1*[z_mat10_sat z_mat10_sun z_rain z_snow z_prec_sat z_prec_sun];
    % namez = [namez_mat10_sat namez_mat10_sun namez_rain namez_snow namez_prec_sat namez_prec_sun];

    % drop the rows from z for which we don't have an outcome
    z = z(days_to_keep,:);

    %% LASSO
    % Partial out x's that need to show up in both stages
    % (for now, already partialed)
    xxinv = inv(x'*x);
    Md = full(d - x*xxinv*(x'*d));
    Mz = full(z - x*xxinv*(x'*z));


    I = find(std(Mz) > 1e-6);
    Mz = Mz(:,I);
    namez = namez(I);

    n = size(Mz,1);

    % % Standardize for LASSO selection
    sd = std(Md);
    Sz_app = (ones(size(Mz,1),1)*std(Mz));
    Md = Md/sd;
    Mz = Mz./Sz_app;

    K = size(Mz,2);

    % Use LASSO to select instruments for several values of tuning parameter
    % For now, 4 options:
    %   1.  Select 1 instrument
    %   2.  Select 2 instruments
    %   3.  Select instruments using data-dependent penalty "A"
    %   4.  Select instruments using data-dependent penalty "L"


    % Select 1 instrument
    [L,IND] = findLambdaK(Mz,Md,1,4000);
    %sum(IND)

    % select 2 instruments
    [L2,IND2] = findLambdaK(Mz,Md,2,4000);
    %sum(IND2)
    v = Md - Mz(:,IND2)*inv(Mz(:,IND2)'*Mz(:,IND2))*(Mz(:,IND2)'*Md);

    % Select with initial penalty loadings
    St = Mz.*(v*ones(1,size(Mz,2)));
    Ups = sqrt(sum(St.^2)/n);
    lambda = c*2*sqrt(2*n*(log(2*(size(Mz,2)))));
    PIpA = LassoShooting(Mz./(ones(n,1)*Ups), Md , lambda);
    INDpA = ( abs(PIpA) > 1.0e-4 );
    %sum(INDpA)
    v = Md - Mz(:,INDpA)*inv(Mz(:,INDpA)'*Mz(:,INDpA))*(Mz(:,INDpA)'*Md);

    % Select with refined penalty loadings
    St = Mz.*(v*ones(1,size(Mz,2)));
    UpsR = sqrt(sum(St.^2)/n);
    PIpL = LassoShooting(Mz./(ones(n,1)*UpsR), Md , lambda);
    INDpL = ( abs(PIpL) > 1.0e-4 );
    %sum(INDpL)


    % of instruments selected with refined penalty loadings, select 1
    [L_a1,IND_a1] = findLambdaK(Mz(:,INDpA) ,Md, 1,4000);
    [L_l1,IND_l1] = findLambdaK(Mz(:,INDpL) ,Md, 1,4000);

    % of instruments selected with refined penalty loadings, select 2
    [L_a2,IND_a2] = findLambdaK(Mz(:,INDpA) ,Md, 2,4000);
    [L_l2,IND_l2] = findLambdaK(Mz(:,INDpL) ,Md, 2,4000);


    % print names of instruments
    fprintf('Opening weather variable names:\n')
    fprintf('Select 1: open_%s\n',namez{IND})
    fprintf('Select 2: open_%s open_%s\n',namez{IND2})

    fprintf('Penalty A: ')
    fprintf('open_%s ',namez{INDpA})
    fprintf('\n')

    fprintf('Penalty L: ')
    fprintf('open_%s ',namez{INDpL})
    fprintf('\n')

    namez_a1 = namez(INDpA);
    fprintf('Penalty A choose 1: ')
    fprintf('open_%s ',namez_a1{IND_a1})
    fprintf('\n')

    namez_l1 = namez(INDpL);
    fprintf('Penalty L choose 1: ')
    fprintf('open_%s ',namez_l1{IND_l1})
    fprintf('\n')

    namez_a2 = namez(INDpA);
    fprintf('Penalty A choose 2: ')
    fprintf('open_%s ',namez_a2{IND_a2})
    fprintf('\n')

    namez_l2 = namez(INDpL);
    fprintf('Penalty L choose 2: ')
    fprintf('open_%s ',namez_l2{IND_l2})
    fprintf('\n\n')
    fprintf('\n\n')


end



