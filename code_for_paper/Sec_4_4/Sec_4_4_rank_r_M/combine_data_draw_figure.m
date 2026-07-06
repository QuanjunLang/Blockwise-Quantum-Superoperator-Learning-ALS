clear all
close all
clc

all_M = 50:10:260;
all_p = 1:14;

Num_M = length(all_M);
Num_p = length(all_p);

Num_samples = 10;
all_M_seq = {50:10:250, 80:10:260, 140:10:260, 180:10:260, 210:10:260};
all_p_seq = {1:2, 3:4, 5:6, 7:9, 10:14};
all_data_seq = {"p_1_4.mat", "p_3_4.mat", "p_5_6.mat", "p_7_9.mat", "p_10_14.mat"};

all_info_seq = cell(5, 1);
% all_info = zeros(Num_p, Num_M, 3);


for i = 1:5
    file_name = all_data_seq{i};
    load(file_name);

    all_M_local = all_M_seq{i};
    all_p_local = all_p_seq{i};

    Num_M_local = length(all_M_local);
    Num_p_local = length(all_p_local);



    all_info_seq{i} = zeros(Num_p_local, Num_M_local, 3);
    for l = 1:Num_p_local
        for m = 1:Num_M_local
            all_info_seq{i}(l, m, 1) = sum(squeeze(all_info(l, 1, m, :)) < 1e-5)/Num_samples;
        end
    end

    for l = 1:Num_p_local
        for m = 1:Num_M_local
            all_info_seq{i}(l, m, 2) = mean(squeeze(all_info(l, 2, m, :)));
        end
    end

    for l = 1:Num_p_local
        for m = 1:Num_M_local
            all_info_seq{i}(l, m, 3) = mean(squeeze(all_info(l, 3, m, :)));
        end
    end

end

all_M = 50:10:260;
all_p = 1:14;

Num_M = length(all_M);
Num_p = length(all_p);
all_info = zeros(Num_p, Num_M, 3);


for i = 1:5
    all_M_local = all_M_seq{i};
    all_p_local = all_p_seq{i};

    M_local_start_ind = sum(all_M < all_M_local(1))+1;

    % i
    % M_local_start_ind
    for k = 1:3
        if i == 1
            all_info(all_p_local, M_local_start_ind:end-1, k) = all_info_seq{i}(:, :, k);
            all_info(all_p_local, end, k) = 1;
        else
            all_info(all_p_local, M_local_start_ind:end, k) = all_info_seq{i}(:, :, k);
        end
    end
end
%

%%

figure;imagesc((all_p), (all_M), all_info(:, :, 1)');colormap(gray);set(gca, 'YDir', 'normal');
xlabel('Number of jump operators: N_J');
ylabel('Number of observables: M_O');

% set(gca, 'FontName', 'Helvetica')
set(gcf, 'Position',  [100, 100, 500, 380]);
set(findall(gcf,'-property','FontSize'),'FontSize',14);
tightfig;
colorbar
colormap(gray);
saveas(gcf, 'Sec_4_4_Necessary_data_size_rank.pdf')

% close all


% figure;imagesc((all_p), (all_M), all_info(:, :, 2)');set(gca, 'YDir', 'normal');colorbar;


% figure;imagesc((all_p), (all_M), all_info(:, :, 3)');set(gca, 'YDir', 'normal');colorbar;


% %%
% figure;hold on;
% for i = 1:Num_M-1
%     ind_success = floor(sum(all_info(:, i, 1)))-1;
%     if ind_success > 0
%         plot(all_p(1:ind_success), all_info(1:ind_success, i, 2));
%     end
% end
% 
% set(gca, 'XScale', 'log', 'YScale', 'log');
% 
% % loglog(all_p, all_info(:, :, 2))
% 
% %%
% 
% figure;
% i = Num_M-2
% ind_success = floor(sum(all_info(:, i, 1)))-4;
% if ind_success > 0
%     plot(all_p(1:ind_success), all_info(1:ind_success, i, 2));
% end
% 
% set(gca, 'XScale', 'log', 'YScale', 'log');