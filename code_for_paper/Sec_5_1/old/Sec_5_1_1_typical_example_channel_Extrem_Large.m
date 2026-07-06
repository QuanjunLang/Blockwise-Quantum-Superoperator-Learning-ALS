clc
close all
clear all
rng(0)
addPaths

% copyright - Quanjun Lang, 2024
%% system settings
pe = pyenv(Version='/opt/anaconda3/bin/python', ExecutionMode = 'OutOfProcess');
terminate(pe)

sysInfo.n               = 64;           %
sysInfo.M               = 450;          % number of independent trajectories
sysInfo.p               = 3;            % number of jumpoperators or Kraus operators

sysInfo.operator_option  = 'Channel';
% sysInfo.operator_option  = 'Lindblad';


dnorm_flag  = 0;
sigma       = 1e-4;
Num_samples = 10;
methods = {'ALS-N', 'ALS-I'};
Num_methods = length(methods);

all_Info = cell(Num_methods, Num_samples);
all_K_est = cell(Num_methods, Num_samples);

for i = 1:Num_samples
    [all_rho, trueInfo, observableInfo] = generate_data(sysInfo, 'plotON', 1);
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

    % %% Total ALS
    % fprintf('\nLearning operator in total:\n')
    % [RK_est_temp, RK_Info_temp] = ALS(A_mat, b_mat, r, 'X_true', RK, 'debugON', 1, 'Acceleration', 'Polyak', 'beta', 0.5, 'rel_err_tol', 1e-6);
    %
    % fprintf('Finished in %.2f seconds \n', RK_Info_temp.time)
    % all_Info{1, i} = error_analysis(RK_Info_temp, RK_est_temp, RK, 'displayON', 1, 'compute_dnorm', dnorm_flag);
    % all_K_est{1, i} = RK_est_temp;


    A = all_O;
    n = sysInfo.n;
    b = zeros(sysInfo.n, sysInfo.M);                % new_b are the measurement result as if we take observables to be E_11, ..., E_1N.
    b(1, :) = all_rho(:, 1).';
    for j = 1:n-1
        b(j+1, :) = (all_rho(:, n+j) -1i*all_rho(:, 2*n-1+j))-(all_rho(:, 1) + all_rho(:, j+1))*(1 - 1i)/2;
    end
    %% First Row Parallel
    % [all_K_est{1, i}, all_Info{1, i}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_parallel', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 3, 'debugON', 0, 'displayON', 1, 'compute_dnorm', dnorm_flag, ...
    %     'ALS_debugON', 0, 'ALS_Acceleration', 'Nesterov', 'plotON', 0);

    %% First Row Joint
    [all_K_est{1, i}, all_Info{1, i}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 0, 'displayON', 1, 'compute_dnorm', dnorm_flag, ...
        'ALS_debugON', 0, 'ALS_Acceleration', 'Nesterov', 'ALS_loss_tol', 1e-8, 'ALS_rel_err_tol', 1e-6);

    %% First Row subset
    [all_K_est{2, i}, all_Info{2, i}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_subset', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 0, 'displayON', 1, 'compute_dnorm', dnorm_flag, ...
        'ALS_debugON', 0, 'ALS_Acceleration', 'Nesterov', 'ALS_loss_tol', 1e-8, 'ALS_rel_err_tol', 1e-6, 'sub_ind_ratio', 0.1);

end


%% prepare the numbers

Num_items = 2;

all_form = zeros(Num_methods, Num_items, Num_samples);

for i = 1:Num_samples
    for m = 1:Num_methods
        all_form(m, 1, i) = all_Info{m, i}.rel_error_fro_X;
        all_form(m, 2, i) = all_Info{m, i}.time;
    end
end

%%


mean1 = mean(squeeze(all_form(:, 1, :))');
std1 = std(squeeze(all_form(:, 1, :))');
mean2 = mean(squeeze(all_form(:, 2, :))');
std2 = std(squeeze(all_form(:, 2, :))');


frob_err = strcat(num2str(mean1', '%.2e'), ' $\pm$ ', num2str(std1', '%.2e'));
time_err = strcat(num2str(mean2', '%.2e'), ' $\pm$ ', num2str(std2', '%.2e'));


% Combine into a table
T = table(methods', frob_err, time_err, ...
    'VariableNames', {'Method', 'Frobenius Error', 'Time(s)'});

% Write to CSV
writetable(T, '5_1_1_Channel_typical_data_Extrem_Large.csv')
writetable(T, '/Users/quanjunlang/Documents/GitHub/Learning-operators-in-Lindblad-Master-Equation-Paper/5_1_1_Channel_typical_data_Extrem_Large.csv')
