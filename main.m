clc
close all
clear all
rng(0)
addPaths

% copyright - Quanjun Lang, 2024
%% system settings
% pe = pyenv(Version='/opt/anaconda3/bin/python', ExecutionMode = 'OutOfProcess');


pe = pyenv( ...
    Version='/opt/anaconda3/envs/blockwise-quantum-superoperator-learning-als/bin/python', ...
    ExecutionMode='OutOfProcess');


terminate(pe)

sysInfo.n               = 10;           %
sysInfo.M               = 80;          % number of independent trajectories
sysInfo.p               = 2;            % number of jumpoperators
% 
sysInfo.operator_option  = 'Channel';
% sysInfo.operator_option  = 'Channel_Pauli';
% sysInfo.operator_option  = 'Lindblad';
%% Generate data

[all_rho, trueInfo, observableInfo] = generate_data(sysInfo, 'plotON', 1);


sigma = 0;
all_rho = all_rho + randn(size(all_rho))*sigma;

%% Prepare A and b for matrix sensing 
K = trueInfo.K_true;
RK = trueInfo.RK_true;
r = trueInfo.rank_RK_true;
RK_sub_blocks = trueInfo.RK_sub_blocks;

all_rho0    = observableInfo.rho0;
all_O       = observableInfo.O;

[A_mat, b_mat, A, b] = prepare_A_b(all_rho0, all_O, all_rho, sysInfo.operator_option);
%% Total ALS
fprintf('\nLearning operator in total:\n')
[RK_est{1}, RK_Info_temp] = ALS(A_mat, b_mat, r, 'X_true', RK, 'debugON', 1, 'Acceleration', 'Polyak', 'beta', 0.4);

fprintf('Finished in %.2f seconds \n', RK_Info_temp.time)
RE_Info{1} = error_analysis(RK_Info_temp, RK_est{1}, RK, 'displayON', 1, 'compute_dnorm', 0);

%% First Row Joint
[RK_est{2}, RK_Info{2}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
    'ALS_debugON', 1, 'ALS_Acceleration', 'Nesterov', 'ALS_loss_tol', 1e-6, 'ALS_rel_err_tol', 1e-6);

%% First Row subset
[RK_est{3}, RK_Info{3}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_subset', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
    'ALS_debugON', 1, 'ALS_Acceleration', 'None', 'ALS_loss_tol', 1e-6, 'ALS_rel_err_tol', 1e-8, 'sub_ind_ratio', 0.4);

%% First Row Parallel
[RK_est{4}, RK_Info{4}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_parallel', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 3, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
    'ALS_debugON', 0, 'ALS_Acceleration', 'Nesterov', 'plotON', 1);
