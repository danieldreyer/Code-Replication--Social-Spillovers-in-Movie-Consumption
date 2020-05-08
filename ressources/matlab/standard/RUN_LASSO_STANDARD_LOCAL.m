% Run IV LASSO program

clear ;
clc ;

c = 1.1; % LASSO penalty multiplier

%% Read in data.

% opening wkend
names1 = importfile('../data/local_daily.csv');


% base case
d = z_searches_res_w0; % endogenous variable

% set up matrix of different cuts of tickets
D = z_searches_res_w0;

nameD = {'z_searches_res_w0'};


%% set up instruments
% Candidate instruments, z:
%%%%% 5 degree increments
z_mat5_sat = [open_mat5_40_res_6, open_mat5_45_res_6, open_mat5_50_res_6, open_mat5_55_res_6, open_mat5_60_res_6, ...
    open_mat5_65_res_6, open_mat5_70_res_6, open_mat5_75_res_6, open_mat5_80_res_6, open_mat5_85_res_6, open_mat5_90_res_6, ...
    open_mat5_95_res_6];
namez_mat5_sat = {'open_mat5_40_res_6', 'open_mat5_45_res_6', 'open_mat5_50_res_6', 'open_mat5_55_res_6', 'open_mat5_60_res_6', ...
    'open_mat5_65_res_6', 'open_mat5_70_res_6', 'open_mat5_75_res_6', 'open_mat5_80_res_6', 'open_mat5_85_res_6', 'open_mat5_90_res_6', ...
    'open_mat5_95_res_6'};

z_mat5_sun = [open_mat5_40_res_0, open_mat5_45_res_0, open_mat5_50_res_0, open_mat5_55_res_0, open_mat5_60_res_0, ...
    open_mat5_65_res_0, open_mat5_70_res_0, open_mat5_75_res_0, open_mat5_80_res_0, open_mat5_85_res_0, open_mat5_90_res_0, ...
    open_mat5_95_res_0];
namez_mat5_sun = {'open_mat5_40_res_0', 'open_mat5_45_res_0', 'open_mat5_50_res_0', 'open_mat5_55_res_0', 'open_mat5_60_res_0', ...
    'open_mat5_65_res_0', 'open_mat5_70_res_0', 'open_mat5_75_res_0', 'open_mat5_80_res_0', 'open_mat5_85_res_0', 'open_mat5_90_res_0', ...
    'open_mat5_95_res_0'};

%%%%% rain, prec, snow for sat/sun
z_rain = [open_rain_res_6 open_rain_res_0];
namez_rain = {'open_rain_res_6' 'open_rain_res_0'};

z_snow = [open_snow_res_6 open_snow_res_0];
namez_snow = {'open_snow_res_6' 'open_snow_res_0'};

z_prec_sat = [open_prec_0_res_6, open_prec_1_res_6, open_prec_2_res_6, ...
    open_prec_3_res_6, open_prec_4_res_6, open_prec_5_res_6];
namez_prec_sat = {'open_prec_0_res_6', 'open_prec_1_res_6', 'open_prec_2_res_6',...
    'open_prec_3_res_6', 'open_prec_4_res_6', 'open_prec_5_res_6'};

z_prec_sun = [open_prec_0_res_0, open_prec_1_res_0, open_prec_2_res_0, ...
    open_prec_3_res_0, open_prec_4_res_0, open_prec_5_res_0];
namez_prec_sun = {'open_prec_0_res_0', 'open_prec_1_res_0', 'open_prec_2_res_0',...
    'open_prec_3_res_0', 'open_prec_4_res_0', 'open_prec_5_res_0'};


for d_ind = 1 : size(D,2)
    d = D(:,d_ind);

    days_to_keep = (isnan(d)==0);
    d = d(days_to_keep);

    fprintf('\nLHS is: %s\n', nameD{d_ind})
    fprintf('Num obs is: %d\n\n', size(d,1))

    % use residualized tickets
    x = ones(size(d,1),1); % exogenous controls



    %%%%% set the instruments to LASSO
    % 5 deg incr for sat, sun and prec and snow and rain
    z = 1*[z_mat5_sat z_mat5_sun z_rain z_snow z_prec_sat z_prec_sun];
    namez = [namez_mat5_sat namez_mat5_sun namez_rain namez_snow namez_prec_sat namez_prec_sun];

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
    % print the names of the instruments

    fprintf('Opening weather variable names:\n')
    fprintf('Select 1: %s',namez{IND})
    fprintf('\n')
    fprintf('Select 2: %s %s',namez{IND2})
    fprintf('\n')

    fprintf('Penalty A: ')
    fprintf('%s ',namez{INDpA})
    fprintf('\n')

    fprintf('Penalty L: ')
    fprintf('%s ',namez{INDpL})
    fprintf('\n')

    namez_a1 = namez(INDpA);
    fprintf('Penalty A choose 1: ')
    fprintf('%s ',namez_a1{IND_a1})
    fprintf('\n')

    namez_l1 = namez(INDpL);
    fprintf('Penalty L choose 1: ')
    fprintf('%s ',namez_l1{IND_l1})
    fprintf('\n')

    namez_a2 = namez(INDpA);
    fprintf('Penalty A choose 2: ')
    fprintf('%s ',namez_a2{IND_a2})
    fprintf('\n')

    namez_l2 = namez(INDpL);
    fprintf('Penalty L choose 2: ')
    fprintf('%s ',namez_l2{IND_l2})
    fprintf('\n\n')
    fprintf('\n\n')
end



