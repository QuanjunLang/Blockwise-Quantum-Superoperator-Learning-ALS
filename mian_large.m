% clc
close all
clear all
rng(0)
addPaths

% copyright - Quanjun Lang, 2024
%% system settings
pe = setup_python();

sysInfo.n               = 64;           %
sysInfo.M               = 500;          % number of independent trajectories
sysInfo.p               = 2;            % number of jumpoperators

% sysInfo.operator_option  = 'Channel';
% sysInfo.operator_option  = 'Channel_Pauli';
sysInfo.operator_option  = 'Lindblad';
%% Generate data

[all_rho, trueInfo, observableInfo] = generate_data(sysInfo, 'plotON', 1);


sigma = 1e-5;
all_rho = all_rho + randn(size(all_rho))*sigma;

%% Prepare A and b for matrix sensing 
K = trueInfo.K_true;
RK = trueInfo.RK_true;
r = trueInfo.rank_RK_true;
RK_sub_blocks = trueInfo.RK_sub_blocks;

all_rho0    = observableInfo.rho0;
all_O       = observableInfo.O;

% [A_mat, b_mat, A, b] = prepare_A_b(all_rho0, all_O, all_rho, sysInfo.operator_option);
% for block-wise ALS

[n, ~, N_initial] = size(all_rho0);
N_observable = length(all_O);
[M, ~] = size(all_rho);

A = all_O;
b = zeros(n, M);                % new_b are the measurement result as if we take observables to be E_11, ..., E_1N.
b(1, :) = all_rho(:, 1).';
for i = 1:n-1
    b(i+1, :) = (all_rho(:, n+i) -1i*all_rho(:, 2*n-1+i))-(all_rho(:, 1) + all_rho(:, i+1))*(1 - 1i)/2;
end
%% First Row subset
[RK_est, RK_Info] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_subset', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
    'ALS_debugON', 1, 'ALS_Acceleration', 'Polyak', 'ALS_beta', 0.7, 'ALS_loss_tol', 1e-6, 'ALS_rel_err_tol', 1e-8, 'sub_ind_ratio', 0.1, 'error_analysis_ON', 0, 'ALS_maxiter', 200);


%%
norm(RK_est - RK, 'fro')/norm(RK, 'fro')