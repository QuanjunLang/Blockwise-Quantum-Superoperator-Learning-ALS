clc
close all
clear all


%%
temp = load('5_1_2_Channel_typical_data.mat', 'all_form');
all_form = temp.all_form;


methods = {'ALS-N^2', 'ALS-P', 'ALS-N', 'ALS-I'};

mean_small = mean(all_form, 3);
std_small  = std(all_form, 0, 3);



frob_err = strcat(num2str(mean_small(:, 1), '%.1e'), ' $\pm$ ', num2str(std_small(:, 1), '%.1e'));
diam_err = strcat(num2str(mean_small(:, 2), '%.1e'), ' $\pm$ ', num2str(std_small(:, 2), '%.1e'));
time_len = strcat(num2str(mean_small(:, 3), '%.3f'), ' $\pm$ ', num2str(std_small(:, 3), '%.3f'));


table_data = cell(3, 5);

table_data{1, 1} = "Frobenius error";
table_data{2, 1} = 'Diamond error';
table_data{3, 1} = 'Time (s)';

for i = 2:5
    table_data{1, i} = string(frob_err(i-1, :));
    table_data{2, i} = [diam_err(i-1, :)];
    table_data{3, i} = [time_len(i-1, :)];
end

table_data;

T1 = cell2table(table_data, 'VariableNames', ["Method", "ALS-N^2", "ALS-P", "ALS-N", "ALS-I"])



%%
temp = load('5_1_2_Channel_typical_data_Large.mat', 'all_form');
all_form = temp.all_form;

mean_Large = mean(all_form, 3);
std_Large  = std(all_form, 0, 3);

frob_err = strcat(num2str(mean_Large(:, 1), '%.1e'), ' $\pm$ ', num2str(std_Large(:, 1), '%.1e'));
time_len = strcat(num2str(mean_Large(:, 2), '%.3f'), ' $\pm$ ', num2str(std_Large(:, 2), '%.3f'));


table_data = cell(2, 5);


table_data{1, 1} = "Frobenius error";
table_data{2, 1} = 'Time (s)';

for i = 2:5
    table_data{1, i} = string(frob_err(i-1, :));
    table_data{2, i} = string(time_len(i-1, :));
end

table_data;

T2 = cell2table(table_data, 'VariableNames', ["Method", "ALS-N^2", "ALS-P", "ALS-N", "ALS-I"])

%%
temp = load('5_1_2_Channel_typical_data_Ex_Large.mat', 'all_form');
all_form = temp.all_form;

mean_ex_Large = mean(all_form, 3)
std_ex_Large  = std(all_form, 0, 3)


frob_err = strcat(num2str(mean_ex_Large(:, 1), '%.1e'), ' $\pm$ ', num2str(std_ex_Large(:, 1), '%.1e'));
time_len = strcat(num2str(mean_ex_Large(:, 2), '%.3f'), ' $\pm$ ', num2str(std_ex_Large(:, 2), '%.3f'));


table_data = cell(2, 5);

table_data{1, 1} = "Frobenius error";
table_data{2, 1} = 'Time (s)';


for i = 2:3
    table_data{1, i} = "*";
    table_data{2, i} = "*";
end


for i = 4:5
    table_data{1, i} = string(frob_err(i-3, :));
    table_data{2, i} = time_len(i-3, :);
end

table_data;

T3 = cell2table(table_data, 'VariableNames', ["Method", "ALS-N^2", "ALS-P", "ALS-N", "ALS-I"])

% T3.Column1 = string(T3.Column1); % Convert to string array
% T3.Column2 = string(T3.Column2); % Convert to string array

writetable([T1;T2;T3], '5_1_2_channel.csv')

