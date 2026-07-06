clc
close all
clear all
rng(0)

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

sysInfo.n               = 16;           %
sysInfo.p               = 1;            % number of jumpoperators


% sysInfo.operator_option  = 'Channel';
% sysInfo.operator_option  = 'Channel_Pauli';
sysInfo.operator_option  = 'Lindblad';


%%
all_M       = 40:5:140;

Num_M = length(all_M);
Num_samples = 10;


all_Info = cell(Num_M, Num_samples);
all_K_est = cell(Num_M, Num_samples);



for i = 1:Num_M
    for k = 1:Num_samples
        
        %% Load parameters
        sysInfo.M = all_M(i);
        fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        fprintf('The %d-th M = %d out of %d total choice, %d-th sample out of %d\n', i, sysInfo.M, Num_M, k, Num_samples)
        fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        %% Generate data
        [all_rho, trueInfo, observableInfo] = generate_data(sysInfo, 'plotON', 1);

        %% Prepare A and b for matrix sensing
        K = trueInfo.K_true;
        RK = trueInfo.RK_true;
        r = trueInfo.rank_RK_true;
        RK_sub_blocks = trueInfo.RK_sub_blocks;

        all_rho0    = observableInfo.rho0;
        all_O       = observableInfo.O;

        [A_mat, b_mat, A, b] = prepare_A_b(all_rho0, all_O, all_rho, sysInfo.operator_option);


        compute_dnorm = 0;
        
        l = 1;
        %% First Row Parallel
        [all_K_est{i, k, l}, all_Info{i, k, l}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_parallel', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 3, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
            'ALS_debugON', 0, 'ALS_Acceleration', 'Nesterov', 'plotON', 0);


        %% First Row Joint
        l = l + 1;
        [all_K_est{i, k, l}, all_Info{i, k, l}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
            'ALS_debugON', 0, 'ALS_Acceleration', 'Nesterov', 'ALS_loss_tol', 1e-6, 'ALS_rel_err_tol', 1e-6);
        
        %% First Row subset

        l = l + 1;
        [all_K_est{i, k, l}, all_Info{i, k, l}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_subset', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
            'ALS_debugON', 0, 'ALS_Acceleration', 'Nesterov', 'ALS_loss_tol', 1e-6, 'ALS_rel_err_tol', 1e-8, 'sub_ind_ratio', 0.5);
        



        % 
        % %% store the numbers
        % all_ALS_P{i, k} = RK_Info;
        % all_ALS_N{i, k} = RK_est_first_row_Info;
        % all_ALS_I{i, k} = RK_est_first_row_Info_subset;


    end
end




%% collect data
Num_items = 2;
Num_methods = 3;


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



all_error = all_error([2, 3, 1], :, :, :);
%% successful recovery rate 
figure;hold on;
colors(1, :) = color1;
colors(2, :) = color2;
colors(3, :) = color3;
% colors(4, :) = color4;

marker{1} = '+';
marker{2} = 'o';
marker{3} = '*';

lineWidth = 2;

lgd{1} = 'ALS-N';
lgd{2} = 'ALS-I';
lgd{3} = 'ALS-P';

for i = 1:Num_methods
    success_points = sum(squeeze(all_error(i, 1, :, :))<1e-5, 2);
    scatter(all_M, success_points, 52, 'Color', colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});
end

legend('Location','best')
ylb = ['# error \leq 1e-05 /', num2str(Num_samples), ' trials'];
ylabel(ylb);
xlabel('Number of independent trials')

tightfig
saveas(gcf, 'Sec_5_2_fast_ALS_rate_Lindblad.pdf')
%% computation time
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

lgd{1} = 'ALS-N';
lgd{2} = 'ALS-I';
lgd{3} = 'ALS-P';


for i = 1:Num_methods
    success_points = median(squeeze(all_error(i, 2, :, :)), 2);
    % if i == 1
    %     yaxix left
    % else
    %     yaxis right
    % end
    scatter(all_M, success_points, 52, 'Color', colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});
end
% set(gca, 'YScale', 'log')

legend('Location','best')
ylb = 'Median computation time (s)';
ylabel(ylb);
xlabel('Number of independent trials')

hfig = tightfig(hfig)

saveas(gcf, 'Sec_5_2_fast_ALS_time_Lindblad.pdf')

%%



save('Lindblad.mat')

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
