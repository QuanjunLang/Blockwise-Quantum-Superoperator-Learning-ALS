clc
% close all
clear all
random_seed = 2;
rng(random_seed);

addPaths

try
    terminate(pe)
catch
    pause(0.01)
end

% copyright - Quanjun Lang, 2024
%% system settings
sysInfo.n               = 4;            %
sysInfo.p               = 2;            % number of jumpoperators

sysInfo.operator_option  = 'Channel';

sysInfo.PAPER_FIG_DIR = 'figure';

pe = pyenv(Version='/opt/anaconda3/bin/python', ExecutionMode = 'OutOfProcess');
terminate(pe)



%%
Num_methods = 4;

lgd{1} = 'FFO';
lgd{2} = 'FRO';
lgd{3} = 'CRO';
lgd{4} = 'TRO';
lgd{5} = 'FRO_Pauli';

all_M       = 5:15;
Num_M = length(all_M);


Num_samples = 5;
all_RK_Info = cell(Num_M, Num_samples, Num_methods);



for i = 1:Num_M
    for k = 1:Num_samples

        %% Load parameters
        sysInfo.M = all_M(i);

        fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        fprintf('The %d-th M = %d out of %d total choice, %d-th sample out of %d\n', i, sysInfo.M, Num_M, k, Num_samples)
        fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        %% Generate data
        [all_rho, trueInfo, observableInfo] = generate_data(sysInfo, 'plotON', 1);
        
        all_rho
        %% Prepare A and b for matrix sensing 
        K = trueInfo.K_true;
        RK = trueInfo.RK_true;
        r = trueInfo.rank_RK_true;
        RK_sub_blocks = trueInfo.RK_sub_blocks;
        
        all_rho0    = observableInfo.rho0;
        all_O       = observableInfo.O;
       
        all_A = cell(4, 1);
        all_b = cell(4, 1);


        [all_A{1}, all_b{1}] = get_A_b_FFO(sysInfo, observableInfo, all_rho);
        [all_A{2}, all_b{2}] = get_A_b_FRO(sysInfo, observableInfo, RK);
        [all_A{3}, all_b{3}] = get_A_b_CRO(sysInfo, observableInfo, RK);
        [all_A{4}, all_b{4}] = get_A_b_TRO(sysInfo, RK);

        [all_A{5}, all_b{5}] = get_A_b_FRO_Pauli(sysInfo, observableInfo, RK);
        compute_dnorm = 0;
        method_list = {'Fixed first row observables', 'Fixed random observables', 'Changed random observables', 'Total random states and observables'};


        for j = 1:Num_methods
            fprintf('\nJoint ALS for the entire matrix, method = %s...\n', method_list{j})

            [RK_est, all_RK_Info{i, k, j}] = ALS(all_A{j}, all_b{j}, r, 'X_true', RK, 'Acceleration', 'Polyak',...
                'beta', 0.5, 'loss_tol', 1e-6, 'rel_err_tol', 1e-7, 'debugON', 0, 'maxIter', 500);

            fprintf('Finished in %.2f seconds \n', all_RK_Info{i, k, j}.time)

            all_RK_Info{i, k, j} = error_analysis(all_RK_Info{i, k, j}, RK_est, RK, 'displayON', 1, 'compute_dnorm', compute_dnorm);
        end

    end
end




%% Extract data
for i = 1:Num_M
    for k = 1:Num_samples
        for j = 1:Num_methods
            all_error(i, k, j) = all_RK_Info{i, k, j}.rel_error_fro_X;
            all_time(i, k, j) = all_RK_Info{i, k, j}.time;
        end
    end
end
%%
hfig = figure;hold on;
colors(1, :) = color1;
colors(2, :) = color2;
colors(3, :) = color3;
colors(4, :) = color4;

marker{1} = '+';
marker{2} = 'o';
marker{3} = '*';
marker{4} = 's';

lineWidth = 2;




for i = 1:Num_methods
    success_rate = sum(all_error(:, :, i)<1e-5, 2);
    scatter(all_M, success_rate, 52, 'Color', colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});
end

legend()

%%

figure;hold on;
for i = 1:Num_methods
    mean_time = mean(all_time(:, :, i), 2);
    scatter(all_M, mean_time, 52, 'Color', colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});
end

legend()

%%
% save('ALL_ALS_0101.mat')