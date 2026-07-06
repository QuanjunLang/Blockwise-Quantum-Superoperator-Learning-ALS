clear all
clc
close all
random_seed = 2;
rng(random_seed);
addPaths



%%
load('Channel_Random_all_error.mat')


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
saveas(gcf, 'Sec_4_2_small_test_rate_channel.pdf')



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
saveas(gcf, 'Sec_4_2_small_test_time_channel.pdf')


%%
load("Channel_Random_Pauli_all_error.mat")

%%

% all_error = all_error([2, 3, 1], :, :, :);
%% successful recovery rate 
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
saveas(gcf, 'Sec_4_2_small_test_rate_channel_Pauli.pdf')



%% computation time
figure;hold on;


for i = 1:Num_methods
    success_points = median(squeeze(all_error(i, 2, :, :)), 2);
    scatter(all_M, success_points, 52, colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});
end


legend('Location','best')
ylb = 'Median computation time (s)';
ylabel(ylb);
xlabel('Number of measurements M')

set(gcf, 'Position',  [100, 100, 600, 300]);
set(findall(gcf,'-property','FontSize'),'FontSize',ftsz);
tightfig(gcf)
saveas(gcf, 'Sec_4_2_small_test_time_channel_Pauli.pdf')

%%