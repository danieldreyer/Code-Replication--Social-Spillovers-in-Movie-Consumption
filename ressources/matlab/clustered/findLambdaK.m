function [L,IND] = findLambdaK(X,y,K,Lambda0)

if nargin < 4,
    Lambda0 = 0;
end
if isempty(Lambda0),
    Lambda0 = 0;
end

L = Lambda0;
PI = LassoShooting(X, y , L);
IND = ( abs(PI) > 1.0e-4 );
k = sum(IND);

iter = 0;
swap = 0;
while k ~= K & iter <= 1000,
    direct = sign(k-K);
    if direct > 0,
        L = L + 5*10^(1-swap);
    else
        L = L - 5*10^(1-swap);
    end
    PI = LassoShooting(X, y , L);
    IND = ( abs(PI) > 1.0e-4 );
    k = sum(IND);
    if direct ~= sign(k-K),
        swap = swap+1;
    end
    iter = iter+1;
end

    
    
