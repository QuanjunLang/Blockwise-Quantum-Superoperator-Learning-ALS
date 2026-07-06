clear all
clc

load("Channel.mat")

close all

all_error_channel = all_error;


load("Lindblad.mat")

close all

all_error_Lindblad = all_error;
%%

all_error_Lindblad = all_error_Lindblad([3, 1, 2], :, :, :);
all_error_channel = all_error_channel([3, 1, 2], :, :, :);

addPaths
%%
marker{1} = 'o';
marker{2} = 'diamond';
marker{3} = 's';

marker{4} = '+';
marker{5} = '>';
marker{6} = 'X';

lgd{1} = 'ALS-P, Channel';
lgd{2} = 'ALS-N, Channel';
lgd{3} = 'ALS-I,  Channel';

lgd{4} = 'ALS-P, Lindbladian';
lgd{5} = 'ALS-N, Lindbladian';
lgd{6} = 'ALS-I,  Lindbladian';


colors(1, :) = color2;
colors(2, :) = color3;
colors(3, :) = color4;
colors(4, :) = color1;
colors(5, :) = color5;
colors(6, :) = color6;


%% successful recovery rate 

% colorss(1, :) = color1;
% colorss(2, :) = color2;
% colorss(3, :) = color3;
% colors(4, :) = color4;



% marker{1} = '+';
% marker{2} = 'o';
% marker{3} = '*';



% lgd{1} = 'ALS-N, Channel';
% lgd{2} = 'ALS-I,  Channel';
% lgd{3} = 'ALS-P, Channel';
% 
% lgd{4} = 'ALS-N, Lindbladian';
% lgd{5} = 'ALS-I,  Lindbladian';
% lgd{6} = 'ALS-P, Lindbladian';

%%
figure;hold on;
lineWidth = 2;

for i = 1:Num_methods
    success_points = sum(squeeze(all_error_channel(i, 1, :, :))<1e-5, 2);
    scatter(all_M, success_points, 52, colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});

    success_points = sum(squeeze(all_error_Lindblad(i, 1, :, :))<1e-5, 2);
    scatter(all_M, success_points, 52, colors(i+3, :), 'Marker', marker{i+3}, 'LineWidth', lineWidth, 'displayname', lgd{i+3});
end

xlim([40, 150])


L = legend('Location','east');

L.Position(2) = L.Position(2) + 0.08; % Move up by 0.05 units
L.Position(1) = L.Position(1) + 0.05; % Move up by 0.05 units

ylb = ['# error \leq 1e-05 /', num2str(Num_samples), ' trials'];
ylabel(ylb);
xlabel('Number of observables M_O')


set(gcf, 'Position',  [100, 100, 600, 300]);
set(findall(gcf,'-property','FontSize'),'FontSize',ftsz);
tightfig(gcf)
saveas(gcf, 'Sec_5_2_fast_ALS_rate_all.pdf')


%% computation time


figure; hold on
for i = 1:Num_methods
    success_points = mean(squeeze(all_error_channel(i, 2, :, :)), 2);
    scatter(all_M, success_points, 52, colors(i, :), 'Marker', marker{i}, 'LineWidth', lineWidth, 'displayname', lgd{i});

    success_points = mean(squeeze(all_error_Lindblad(i, 2, :, :)), 2);
    scatter(all_M, success_points, 52, colors(i+3, :), 'Marker', marker{i+3}, 'LineWidth', lineWidth, 'displayname', lgd{i+3});
end
% set(gca, 'YScale', 'log')
xlim([40, 150])

L = legend('Location','northeast');

% L.Position(2) = L.Position(2) + 0.05; % Move up by 0.05 units


ylb = 'Mean computation time (s)';
ylabel(ylb);
xlabel('Number of observables M_O')

set(gcf, 'Position',  [100, 100, 600, 300]);
set(findall(gcf,'-property','FontSize'),'FontSize',ftsz);
tightfig(gcf)

saveas(gcf, 'Sec_5_2_fast_ALS_time_all.pdf')


