% Monte Carlo for panel Lasso paper
% 12/9/13
% AR(1) design with FE
% Version 1

clear ;

% try %#ok<*TRYNC>
%     matlabpool close ;
% end
% 
% matlabpool local 10 ;

rng(78779) ;

% DGP parameters
n = 50;
T = 10;
N = n*T;
p = ceil((T-(-2))*n);

arx = .8;  % Autoregressive coefficients for x
are = .8;  % Autoregressive coefficients for errors
Sx = toeplitz(.5.^(0:p-1));  % Covariance between x innovations
SF = toeplitz(.5.^(0:n-1));  % Covariance between fixed effects
rue = .8;  % Correlation between first-stage and structural error

beta = (1)*((-1).^(0:(p-1))./((1:p).^2))';  % Quadratically decaying, alternating coefficients

alpha = .5;  % "Treatment" effect

group = kron((1:n)',ones(T,1));
time = kron(ones(n,1),(1:T)');
Dt = dummyvar(group);  % Fixed effect dummy variables

% Condition on realization of fixed effects and covariates because
% generating them is annoying
FixedEffects = (2/sqrt(T))*sqrtm(SF)*randn(n,1);      
uX = randn(N,p)*sqrtm(Sx);
X = zeros(N,p);
for jj = 1:p
    xtemp = zeros(T,n);
    xtemp(1,:) = FixedEffects'/(1-arx) + sqrt(1/(1-arx^2))*(uX(time == 1,jj))';
    for kk = 2:T
        xtemp(kk,:) = FixedEffects' + arx*xtemp(kk-1,:) + (uX(time == kk,jj))';
    end
    X(:,jj) = reshape(xtemp,N,1);
end
% Partial out FE
Xp = X - Dt*(Dt\X);
Xc = [X Dt] - ones(N,1)*mean([X Dt]);

% Lasso penalty parameters
levelH = .1/log(N);
levelC = .1/log(n);
lambdaH = 2.2*sqrt(N)*norminv(1-levelH/(2*p));
lambdaC = 2.2*sqrt(n)*norminv(1-levelC/(2*p));

% Simulation Elements
nSim = 1 ;
aO = zeros(nSim,1);
aFO = zeros(nSim,1);
aA = zeros(nSim,1);
aSH = zeros(nSim,1);
aDH = zeros(nSim,1);
aDC = zeros(nSim,1);
seO = zeros(nSim,2);
seFO = zeros(nSim,2);
seA = zeros(nSim,2);
seSH = zeros(nSim,2);
seDH = zeros(nSim,2);
seDC = zeros(nSim,2);

% parfor ii = 1:nSim
for ii = 1:nSim
    if floor((ii-1)/20) == (ii-1)/20
%         disp('Running...');
        disp(ii);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate simulation data
    
    % Generate treatment and outcome error
    u = zeros(T,n);
    e = zeros(T,n);
    temp = sqrtm([1 rue ; rue 1])*randn(2,n);
    u(1,:) = sqrt(1/(1-are^2))*temp(1,:);
    e(1,:) = sqrt(1/(1-are^2))*temp(2,:);
    for kk = 2:T
        temp = sqrtm([1 rue ; rue 1])*randn(2,n);
        u(kk,:) = are*u(kk-1,:) + temp(1,:);
        e(kk,:) = are*e(kk-1,:) + temp(2,:);
    end
    u = reshape(u,N,1);
    e = reshape(e,N,1);
    
    % Generate treatment and outcome
    optIV = X*beta;
    sigD = optIV + Dt*FixedEffects;
    sigY = Dt*FixedEffects;
    
    d = sigD + u;
    y = alpha*d + sigY + e;    
    
    % Subtract sample means
    dC = d - mean(d);
    yC = y - mean(y);

    % Partial out FE
    Yp = y - Dt*(Dt\y);
    Dp = d - Dt*(Dt\d);    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Oracle model
    
    aO(ii,1) = (optIV'*d)\(optIV'*(y-sigY));
    resid = (y-sigY)-aO(ii,1)*d;
    s1 = hetero_se(optIV,resid,1/(optIV'*d));
    s2 = cluster_se(optIV,resid,1/(optIV'*d),group);
    seO(ii,:) = [ s1 s2 ];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fixed Effects Oracle model
    
    optIVFE = Xp*beta;
    aFO(ii,1) = (optIVFE'*Dp)\(optIVFE'*Yp);
    resid = Yp-aFO(ii,1)*Dp;
    s1 = hetero_se(optIVFE,resid,1/(optIVFE'*Dp));
    s2 = cluster_se(optIVFE,resid,1/(optIVFE'*Dp),group);
    seFO(ii,:) = [ s1 s2 ];    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use all variables
    if p + n < N
        dhat = Xp*(Xp\Dp);
        aA(ii,1) = (dhat'*Dp)\(dhat'*Yp);
        resid = Yp - aA(ii,1)*Dp;
        s1 = hetero_se(dhat,resid,1/(dhat'*Dp));
        s2 = cluster_se(dhat,resid,1/(dhat'*Dp),group);
        seA(ii,:) = [ s1(1,1) s2(1,1) ];
    else
        aA(ii,1) = NaN;
        seA(ii,:) = [NaN NaN];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Instrument selection after partialing out FE
    
    % Partial out FE
    Yp = y - Dt*(Dt\y);
    Dp = d - Dt*(Dt\d);
    
    % Heteroskedastic penalty loadings
    ssD = feasiblePostLasso(Dp,Xp,'lambda',lambdaH);    
    use = logical(abs(ssD) > 0);
    if sum(use) > 0
        zUse = Xp(:,use);
        dhat = zUse*(zUse\Dp);
        aDH(ii,1) = (dhat'*Dp)\(dhat'*Yp);
        resid = Yp - aDH(ii,1)*Dp;
        s1 = hetero_se(dhat,resid,1/(dhat'*Dp));
        s2 = cluster_se(dhat,resid,1/(dhat'*Dp),group);
        seDH(ii,:) = [ s1(1,1) s2(1,1) ];
    else
        aDH(ii,1) = NaN;
        seDH(ii,:) = [NaN NaN];
    end
        
    % Clustered penalty loadings
    ssD = feasiblePostLasso(Dp,Xp,'lambda',lambdaC,'clusterVar',group);    
    use = logical(abs(ssD) > 0);
    if sum(use) > 0
        zUse = Xp(:,use);
        dhat = zUse*(zUse\Dp);
        aDC(ii,1) = (dhat'*Dp)\(dhat'*Yp);
        resid = Yp - aDC(ii,1)*Dp;
        s1 = hetero_se(dhat,resid,1/(dhat'*Dp));
        s2 = cluster_se(dhat,resid,1/(dhat'*Dp),group);
        seDC(ii,:) = [ s1(1,1) s2(1,1) ];
    else
        aDC(ii,1) = NaN;
        seDC(ii,:) = [NaN NaN];
    end
    
end

BIAS = mean([aO aFO aA aDH aDC]) - alpha;
RMSE = sqrt(mean(([aO aFO aA aDH aDC] - alpha).^2));
SIZEH = [mean(abs(aO-alpha)./seO(:,1) > 1.96) mean(abs(aFO-alpha)./seFO(:,1) > 1.96) ...
        mean(abs(aA-alpha)./seA(:,1) > 1.96) ...
        mean(abs(aDH-alpha)./seDH(:,1) > 1.96) mean(abs(aDC-alpha)./seDC(:,1) > 1.96)] ;
SIZEC = [mean(abs(aO-alpha)./seO(:,2) > 1.96) mean(abs(aFO-alpha)./seFO(:,2) > 1.96) ...
        mean(abs(aA-alpha)./seA(:,2) > 1.96) ...
        mean(abs(aDH-alpha)./seDH(:,2) > 1.96) mean(abs(aDC-alpha)./seDC(:,2) > 1.96)] ;
    
save IVInf_FEDesignQuadDecay_n50T10p600_rhox8rhoe8 ;
