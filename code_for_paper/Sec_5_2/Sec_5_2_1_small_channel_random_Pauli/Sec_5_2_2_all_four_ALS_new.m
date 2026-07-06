clc
close all
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
pe = pyenv(Version='/opt/anaconda3/bin/python', ExecutionMode = 'OutOfProcess');
terminate(pe)

sysInfo.n               = 4;           %
sysInfo.p               = 2;            % number of jumpoperators


sysInfo.operator_option  = 'Channel';
% sysInfo.operator_option  = 'Channel_Pauli';
% sysInfo.operator_option  = 'Lindblad';


%%
all_M       = 5:1:17;

Num_M = length(all_M);
Num_samples = 20;

Num_methods = 5;

all_Info = cell(Num_M, Num_samples, Num_methods);
all_K_est = cell(Num_M, Num_samples, Num_methods);



for i = 1:Num_M
    for k = 1:Num_samples
        
        %% Load parameters
        sysInfo.M = all_M(i);
        fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        fprintf('The %d-th M = %d out of %d total choice, %d-th sample out of %d\n', i, sysInfo.M, Num_M, k, Num_samples)
        fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        %% Generate data
        [all_rho, trueInfo, observableInfo] = generate_data(sysInfo, 'plotON', 1);

        % all_rho
        %% Prepare A and b for matrix sensing
        K = trueInfo.K_true;
        RK = trueInfo.RK_true;
        r = trueInfo.rank_RK_true;
        RK_sub_blocks = trueInfo.RK_sub_blocks;

        all_rho0    = observableInfo.rho0;
        all_O       = observableInfo.O;

        [A_mat_FFO, b_mat_FFO, A, b] = prepare_A_b(all_rho0, all_O, all_rho, sysInfo.operator_option);


        compute_dnorm = 0;
        



        l = 1;
        %% Total ALS using Total random observables and density matrices
        fprintf('\nLearning operator in total with random states and observables:\n')
        [A_mat_TRO, b_mat_TRO] = get_A_b_TRO(sysInfo, RK);

        total_iter = 6;
        for t = 1:total_iter
            if t > 1
                fprintf('%d-th retry: ', t-1);
            end
            [all_K_est{i, k, l}, RK_Info_temp] = ALS(A_mat_TRO, b_mat_TRO, r, 'X_true', RK, 'Acceleration', 'None',...
                'beta', 0.5, 'loss_tol', 1e-8, 'rel_err_tol', 1e-7, 'debugON', 0, 'maxIter', 500);

            fprintf('Finished in %.2f seconds \n', RK_Info_temp.time)
            all_Info{i, k, l} = error_analysis(RK_Info_temp, all_K_est{i, k, l}, RK, 'displayON', 1, 'compute_dnorm', 0);
            flag = RK_Info_temp.convergence_flag;
            if flag == 1
                break
            end
        end


        %% Total ALS using Total random observables and density matrices
        l = l + 1;

        fprintf('\nLearning operator in total with fixed states and observables:\n')

        % total_iter = 4;
        % for t = 1:total_iter
        %     if t > 1
        %         fprintf('%d-th retry: ', t-1);
        %     end
            [all_K_est{i, k, l}, RK_Info_temp] = ALS(A_mat_FFO, b_mat_FFO, r, 'X_true', RK, 'Acceleration', 'None',...
                'beta', 0.5, 'loss_tol', 1e-8, 'rel_err_tol', 1e-7, 'debugON', 0, 'maxIter', 500);

            fprintf('Finished in %.2f seconds \n', RK_Info_temp.time)
            all_Info{i, k, l} = error_analysis(RK_Info_temp, all_K_est{i, k, l}, RK, 'displayON', 1, 'compute_dnorm', 0);
            % flag = RK_Info_temp.convergence_flag;
        %     if flag == 1
        %         break
        %     end
        % end




        
        %% First Row Parallel
        l = l + 1;
        [all_K_est{i, k, l}, all_Info{i, k, l}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_parallel', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 3, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
            'ALS_debugON', 0, 'ALS_Acceleration', 'None', 'plotON', 0, 'ALS_loss_tol', 1e-8, 'ALS_rel_err_tol', 1e-8, 'num_retry', 5);


        %% First Row Joint
        l = l + 1;
        [all_K_est{i, k, l}, all_Info{i, k, l}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
            'ALS_debugON', 0, 'ALS_Acceleration', 'None', 'ALS_loss_tol', 1e-8, 'ALS_rel_err_tol', 1e-8, 'num_retry', 5);
        
        %% First Row subset

        l = l + 1;
        [all_K_est{i, k, l}, all_Info{i, k, l}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_subset', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
            'ALS_debugON', 0, 'ALS_Acceleration', 'None', 'ALS_loss_tol', 1e-7, 'ALS_rel_err_tol', 1e-7, 'sub_ind_ratio', 0.5, 'num_retry', 5);
        

    end
end

%%
% lgd{1} = 'ALS-N^2, TRO';
% lgd{2} = 'ALS-P';
% lgd{3} = 'ALS-N';
% lgd{4} = 'ALS-I';

lgd{1} = 'ALS-N^2, Random';
lgd{2} = 'ALS-N^2, Fixed';
lgd{3} = 'ALS-P';
lgd{4} = 'ALS-N';
lgd{5} = 'ALS-I';




%% collect data
Num_items = 2;
% Num_methods = 4;


all_error = zeros(Num_methods, Num_items, Num_M, Num_samples);

for i = 1:Num_M
    for k = 1:Num_samples
        for l = 1:Num_methods
            try
                all_error(l, 1, i, k) = all_Info{i, k, l}.rel_error_fro_X;
            catch
                all_error(l, 1, i, k) = 100;
            end
            all_error(l, 2, i, k) = all_Info{i, k, l}.time;
        end
    end
end



% all_error = all_error([2, 3, 1], :, :, :);
%% successful recovery rate 

%%
% lgd{1} = 'ALS-N^2, TRO';
% lgd{2} = 'ALS-P';
% lgd{3} = 'ALS-N';
% lgd{4} = 'ALS-I';

lgd{1} = 'ALS-N^2, Random';
lgd{2} = 'ALS-N^2, Fixed';
lgd{3} = 'ALS-P';
lgd{4} = 'ALS-N';
lgd{5} = 'ALS-I';




figure;hold on;
colors(1, :) = color1;
colors(2, :) = color5;
colors(3, :) = color2;
colors(4, :) = color3;
colors(5, :) = color4;

marker{1} = '+';
marker{2} = '+';
marker{3} = 'o';
marker{4} = 'diamond';
marker{5} = 's';


lineWidth = 2;



for i = 1:Num_methods
    success_points = sum(squeeze(all_error(i, 1, :, :))<1e-5, 2);
    scatter(all_M*10, success_points, 52, colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});
end

legend('Location','best')
ylb = ['# error \leq 1e-05 /', num2str(Num_samples), ' trials'];
ylabel(ylb);
xlabel('Number of measurements M')

set(gcf, 'Position',  [100, 100, 600, 300]);
set(findall(gcf,'-property','FontSize'),'FontSize',ftsz);
tightfig(gcf)
saveas(gcf, 'Sec_5_2_small_test_rate_channel.pdf')



%% computation time
figure;hold on;


for i = 1:Num_methods
    success_points = mean(squeeze(all_error(i, 2, :, :)), 2);
    scatter(all_M, success_points, 52, colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});
end


legend('Location','best')
ylb = 'Median computation time (s)';
ylabel(ylb);
xlabel('Number of independent trials')

set(gcf, 'Position',  [100, 100, 600, 300]);
set(findall(gcf,'-property','FontSize'),'FontSize',ftsz);
tightfig(gcf)
saveas(gcf, 'Sec_5_2_small_test_time_channel.pdf')

%%

save('Channel_Random.mat')
%% computation time (two figures)

% colors(1, :) = color1;
% colors(2, :) = color2;
% colors(3, :) = color3;
% colors(4, :) = color4;
% 
% marker{1} = '+';
% marker{2} = 'o';
% marker{3} = '*';
% marker{4} = 's';
% 
% lineWidth = 2;
% 
% lgd{1} = 'ALS-N^2';
% lgd{2} = 'ALS-P';
% lgd{3} = 'ALS-N';
% lgd{4} = 'ALS-I';
% 
% 
% hfig = figure;
% subplot(211);hold on;
% % tiledlayout(2, 1, 'padding', 'tight');
% % nexttile;
% i = 1;
% success_points = median(squeeze(all_error(i, 2, :, :)), 2);
% scatter(all_M, success_points, 52, 'Color', colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});
% legend('Location','best')
% 
% 
% subplot(212);
% % nexttile;
% hold on;
% for i = 2:4
%     success_points = median(squeeze(all_error(i, 2, :, :)), 2);
%     scatter(all_M, success_points, 52, 'Color', colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});
% end
% % set(gca, 'YScale', 'log')
% 
% legend('Location','best')
% ylb = 'Median computation time (s)';
% ylabel(ylb);
% xlabel('Number of independent trials')
% 
% hfig = tightfig(hfig);
%% save data
% save('M_15_79_Nsamples_20.mat')
















%%


% 
% %%
% figure;hold on
% colors = colororder;
% for i = 1:Num_M
%     scatter(all_n, squeeze(log10(all_error(i, :, :))), 500, '.', 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :))
% end
% % plot(all_n, all_n.*log(all_n)*trueInfo.rank_RL_true)
% %%
% figure;hold on
% colors = colororder;
% for i = 1:Num_n
%     for k = 1:Num_samples
%         if k==1
%             vs = 'on';
%         else
%             vs = 'off';
%         end
%         lgd = ['n = ', num2str(all_n(i))];
%         scatter(all_M, squeeze(log10(all_error(:, i, k))), 100, 'o', 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :), 'DisplayName', lgd,'HandleVisibility', vs)
%     end
% end
% 
% 
% % Convert vector to string for legend
% legendStrings = arrayfun(@num2str, all_n, 'UniformOutput', false);
% % Add the legend using the vector
% % legend(legendStrings, 'Location', 'best');
% legend()
% 
% xlabel('M')
% ylabel('log 10 relative error')
% 
% 
% %%
% figure;hold on;grid on;view(20, 20);
% [XX, YY] = meshgrid(all_n, all_M);
% 
% for k = 1:Num_samples
%     scatter3(XX, YY, squeeze(log10(all_error(:, :, k))), 500, 'k.');
% end
% % scatter3(XX, YY, all_error)
% 
% 
% % Define the grid for x and z
% [x, z] = meshgrid(-2*pi:0.1:2*pi, -2*pi:0.1:2*pi);
% 
% % Calculate y as a function of x
% f = @(x) x.*log(x)*trueInfo.rank_RL_true;
% 
% 
% y = f(XX);
% 
% ee = linspace(log10(min(all_error, [], 'all')), log10(max(all_error, [], 'all')), Num_M);
% [~, ZZ] = meshgrid(all_n, ee);
% surf(XX, y, ZZ)
% ylabel('M')
% xlabel('n')
% 
% 
% 
% %%
% figure;hold on;grid on;view(0, 90);
% all_percent = sum(all_error<0.01, 3)/Num_samples;
% % plot(all_n, f(all_n), 'k', 'LineWidth',20)
% % surf(XX, YY, all_percent)
% 
% % heatmap(all_percent, 'Colormap', jet)
% 
% imagesc(all_n, all_M, all_percent)
% colormap('autumn')
% plot(all_n, f(all_n), 'k', 'LineWidth', 5)
% text(all_n(end-1), f(all_n(end-1))+20, 'M=rnlog(n)')
% 
% % s = 0.2;
% % g = @(x) x.*log(x)*trueInfo.rank_RL_true./x.^s+30;
% % plot(all_n, g(all_n), 'k', 'LineWidth', 5)
% colorbar
% 
% xlabel('System size n')
% ylabel('Trajectory number M')
% title('Recovery rate')
% 
% set(findall(gcf, '-property', 'FontSize'), 'FontSize', 14);
% 
% %% Time analysis
% figure;hold on;grid on;view(20, 20);
% [XX, YY] = meshgrid(all_n, all_M);
% 
% for k = 1:Num_samples
%     scatter3(XX, YY, squeeze(log10(all_time(:, :, k))), 500, 'k.');
% end
% 
% ylabel('M')
% xlabel('n')
% 
% 
% 
