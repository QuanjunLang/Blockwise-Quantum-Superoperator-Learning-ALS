clc
close all
clear all
rng(0)
addPaths

% copyright - Quanjun Lang, 2024
%% system settings
pe = setup_python();

sysInfo.n               = 25;           %
% sysInfo.M               = 1000;          % number of independent trajectories
sysInfo.p               = 2;            % number of jumpoperators
% 
% sysInfo.operator_option  = 'Channel';
% sysInfo.operator_option  = 'Channel_Pauli';
sysInfo.operator_option  = 'Lindblad';


sigma = 1e-3;

Num_M = 20;
all_M = floor(10.^linspace(1.5, 3.5, Num_M));

Num_samples = 10;

Num_method = 5;

RK_est  = cell(Num_method, Num_M, Num_samples);
RK_Info = cell(Num_method, Num_M, Num_samples);



for m = 1:Num_M
    for k = 1:Num_samples
        
        sysInfo.M = all_M(m);
        %% Generate data

        [all_rho, trueInfo, observableInfo] = generate_data(sysInfo, 'plotON', 1);


        
        all_rho = all_rho + randn(size(all_rho))*sigma;

        %% Prepare A and b for matrix sensing
        K = trueInfo.K_true;
        RK = trueInfo.RK_true;
        r = trueInfo.rank_RK_true;
        RK_sub_blocks = trueInfo.RK_sub_blocks;

        all_rho0    = observableInfo.rho0;
        all_O       = observableInfo.O;



        [A, b] = prepare_A_b_first_row(all_rho0, all_O, all_rho);
        % %% First Row Joint
        % [RK_est{1, m, k}, RK_Info{1, m, k}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
        %     'ALS_debugON', 0, 'ALS_Acceleration', 'Polyak', 'ALS_beta', 0.7, 'ALS_loss_tol', 1e-6, 'ALS_rel_err_tol', 0.2*sigma, 'ALS_maxiter', 100, 'ALS_loss_plateau', 0.1);
        


        for t = 1:Num_method
            sub_ind_rate = 1/Num_method*t;
            % First Row subset
            [RK_est{t, m, k}, RK_Info{t, m, k}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_subset', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
                'ALS_debugON', 0, 'ALS_Acceleration', 'Polyak', 'ALS_beta', 0.7, 'ALS_loss_tol', 1e-6, 'ALS_rel_err_tol', 0.2*sigma, 'sub_ind_ratio', sub_ind_rate, 'ALS_maxiter', 100, 'ALS_loss_plateau', 0.06);
        end


        %%

    end
end


%%

Num_items = 5;

% Pre-allocate a numeric array for all_info
all_info = zeros(Num_method, Num_items, Num_M, Num_samples);


for m = 1:Num_M
    for k = 1:Num_samples
        for l = 1:Num_method
            
            % 1) rel_error_fro_X
            try
                all_info(l, 1, m, k) = RK_Info{l, m, k}.rel_error_fro_X;
            catch
                all_info(l, 1, m, k) = 100;
            end
            
            % 2) time
            all_info(l, 2, m, k) = RK_Info{l, m, k}.time;

            % 3) ALS_Info.iters
            try
                all_info(l, 3, m, k) = RK_Info{l, m, k}.ALS_info.iters;
            catch
                all_info(l, 3, m, k) = 100;
            end
           
          
        end
    end
end

%%
colors(1, :) = color1;
colors(2, :) = color5;
colors(3, :) = color2;
colors(4, :) = color3;
colors(5, :) = color4;



make_plot
%%

figure;
tiledlayout(1, 3, 'Padding','compact', 'TileSpacing','tight');


nexttile;hold on;grid on;

for t = 1:Num_method
    plot(log10(all_M), log10(squeeze(all_info(t, 1, :, :))), '+', 'Color', colors(t, :), 'MarkerSize', 5, 'LineWidth', 2)
end



nexttile;hold on;grid on;

for t = 1:Num_method
    plot(log10(all_M), log10(squeeze(all_info(t, 2, :, :))), '+', 'Color', colors(t, :), 'MarkerSize', 5, 'LineWidth', 2)
end


nexttile;hold on;grid on;

for t = 1:Num_method
    plot(log10(all_M), log10(squeeze(all_info(t, 3, :, :))), '+', 'Color', colors(t, :), 'MarkerSize', 5, 'LineWidth', 2)
end


set(gcf, 'Position',  [100, 100, 1200, 250]);
set(findall(gcf,'-property','FontSize'),'FontSize',ftsz);
tightfig(gcf)
% saveas(gcf, 'Sec_5_2_small_test_time_channel.pdf')


%%
figure;hold on;

for t = 1:Num_method
    plot(all_M, squeeze(all_info(t, 2, :, :)), '+', 'Color', colors(t, :), 'MarkerSize', 5, 'LineWidth', 2)
end

%%
figure;hold on;

for t = 1:Num_method
    plot((all_M), (squeeze(all_info(t, 3, :, :))), '+', 'Color', colors(t, :), 'MarkerSize', 5, 'LineWidth', 2)
end

