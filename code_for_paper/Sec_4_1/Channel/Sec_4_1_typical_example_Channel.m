clc
close all
clear all
rng(0)
addPaths

% copyright - Quanjun Lang, 2024
%% system settings
pe = setup_python();

sysInfo.n               = 8;           %
sysInfo.M               = 50;          % number of independent trajectories
sysInfo.p               = 3;            % number of jumpoperators

sysInfo.operator_option  = 'Channel';
% sysInfo.operator_option  = 'Lindblad';


dnorm_flag  = 1;
sigma       = 1e-4;
Num_samples = 10;
methods = {'ALS-$N^2$', 'ALS-P', 'ALS-N', 'ALS-I'};
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

    [A_mat, b_mat, A, b] = prepare_A_b(all_rho0, all_O, all_rho, sysInfo.operator_option);
    % %% Total ALS
    % fprintf('\nLearning operator in total:\n')
    % [RK_est_temp, RK_Info_temp] = ALS(A_mat, b_mat, r, 'X_true', RK, 'debugON', 0, 'Acceleration', 'Polyak', 'beta', 0.3);
    % 
    % fprintf('Finished in %.2f seconds \n', RK_Info_temp.time)
    % all_Info{1, i} = error_analysis(RK_Info_temp, RK_est_temp, RK, 'displayON', 1, 'compute_dnorm', dnorm_flag);
    % all_K_est{1, i} = RK_est_temp;

    %% Total ALS using Total random observables and density matrices
    fprintf('\nLearning operator in total with random states and observables:\n')
    [A_mat_TRO, b_mat_TRO] = get_A_b_TRO(sysInfo, RK);
    b_mat_TRO = b_mat_TRO + randn(size(b_mat_TRO))*sigma;

    [all_K_est{1, i}, RK_Info_temp] = ALS(A_mat_TRO, b_mat_TRO, r, 'X_true', RK, 'Acceleration', 'None',...
        'beta', 0.3, 'loss_tol', 1e-8, 'rel_err_tol', 1e-7, 'debugON', 0, 'maxIter', 500);

    fprintf('Finished in %.2f seconds \n', RK_Info_temp.time)
    all_Info{1, i} = error_analysis(RK_Info_temp, all_K_est{1, i}, RK, 'displayON', 1, 'compute_dnorm', dnorm_flag);








    %% First Row Parallel
    [all_K_est{2, i}, all_Info{2, i}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_parallel', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 3, 'debugON', 0, 'displayON', 1, 'compute_dnorm', dnorm_flag, ...
        'ALS_debugON', 0, 'ALS_Acceleration', 'None', 'plotON', 0);

    %% First Row Joint
    [all_K_est{3, i}, all_Info{3, i}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 0, 'displayON', 1, 'compute_dnorm', dnorm_flag, ...
        'ALS_debugON', 0, 'ALS_Acceleration', 'None', 'ALS_loss_tol', 1e-8, 'ALS_rel_err_tol', 1e-8);

    %% First Row subset
    [all_K_est{4, i}, all_Info{4, i}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_subset', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 0, 'displayON', 1, 'compute_dnorm', dnorm_flag, ...
        'ALS_debugON', 0, 'ALS_Acceleration', 'None', 'ALS_loss_tol', 1e-8, 'ALS_rel_err_tol', 1e-8, 'sub_ind_ratio', 0.4);

end


%% prepare the numbers

Num_items = 3;

all_form = zeros(4, Num_items, Num_samples);

for i = 1:Num_samples
    for m = 1:Num_methods
        all_form(m, 1, i) = all_Info{m, i}.rel_error_fro_X;
        all_form(m, 2, i) = all_Info{m, i}.error_diamond;
        all_form(m, 3, i) = all_Info{m, i}.time;
    end
end



save('4_1_Channel_typical_data.mat', "all_form")
%%


% mean1 = mean(squeeze(all_form(:, 1, :))');
% std1 = std(squeeze(all_form(:, 1, :))');
% mean2 = mean(squeeze(all_form(:, 2, :))');
% std2 = std(squeeze(all_form(:, 2, :))');
% mean3 = mean(squeeze(all_form(:, 3, :))');
% std3 = std(squeeze(all_form(:, 3, :))');
%
%
% frob_err = strcat(num2str(mean1', '%.2e'), ' $\pm$ ', num2str(std1', '%.2e'));
% diamond_err = strcat(num2str(mean2', '%.2e'), ' $\pm$ ', num2str(std2', '%.2e'));
% time_err = strcat(num2str(mean3', '%.2e'), ' $\pm$ ', num2str(std3', '%.2e'));
%
%
% % Combine into a table
% T = table(methods', frob_err, diamond_err, time_err, ...
%     'VariableNames', {'Method', 'Frobenius Error', 'Diamond Error', 'Time(s)'});
%
% % Write to CSV
% writetable(T, '5_1_2_Lindbladian_typical_data.csv')
