clc

ind = 3;

n = sysInfo.n;
K = trueInfo.K_true;
% RK = trueInfo.RK_true;

% Using density matrix 
% rho0 = all_rho(:, :, 1, ind);
% rho1 = all_rho(:, :, 2, ind);
% rho0_prime = (rho1 - rho0)/dt;

% Using arbitrary matrix to test
% rho0 = randn(n, n) + 1i*randn(n, n);

rho0 = zeros(n, n); rho0(2, 3) = 1;

rho1 = reshape(K*vec(rho0), [n, n]);

%% Observable test

O = randn(n, n) + 1i*randn(n, n);
%%
% rho0 = rho0 + rho0';
O = O + O'

%%


u = vec(O);
v = vec(rho0);


v' * K' * u

%% 
A = kron(conj(rho0), O);
B = kron(rho0, conj(O));
C = kron(rho0.', O');

trace(RK'*A)
trace(C'*RK)

trace(O*RK_sub_blocks{3, 2})