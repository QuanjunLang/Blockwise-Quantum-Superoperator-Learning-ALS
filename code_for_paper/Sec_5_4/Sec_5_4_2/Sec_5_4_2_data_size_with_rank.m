clc
close all
clear all
rng(0)
addPaths

% copyright - Quanjun Lang, 2024
%% system settings
pe = pyenv(Version='/opt/anaconda3/bin/python', ExecutionMode = 'OutOfProcess');
terminate(pe)

sysInfo.n               = 16;           %
sysInfo.M               = 500;          % number of independent trajectories
% sysInfo.p               = 2;            % number of jumpoperators or Kraus operators
% 
% sysInfo.operator_option  = 'Channel';
% sysInfo.operator_option  = 'Channel_Pauli';
sysInfo.operator_option  = 'Lindblad';


Num_samples = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sigma = 0;
% sub_ind_rate = 0.5; 
% 
% all_p = 1:1:14;
% Num_p = length(all_p);
% 
% 
% all_M = 50:10:260;
% Num_M = length(all_M);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sigma = 0;
% sub_ind_rate = 0.5;
% 
% all_p = 5:1:7;
% Num_p = length(all_p);
% 
% 
% all_M = 120:10:260;
% Num_M = length(all_M);
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% sigma = 0;
% sub_ind_rate = 0.5;
% 
% all_p = 5:1:6;
% Num_p = length(all_p);
% 
% 
% all_M = 140:10:260;
% Num_M = length(all_M);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% sigma = 0;
% sub_ind_rate = 0.5;
% 
% all_p = 7:1:9;
% Num_p = length(all_p);
% 
% 
% all_M = 180:10:260;
% Num_M = length(all_M);
% 
% Num_samples = 10;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sigma = 0;
% sub_ind_rate = 0.5;
% 
% all_p = 10:1:14;
% Num_p = length(all_p);
% 
% 
% all_M = 210:10:260;
% Num_M = length(all_M);
% 
% Num_samples = 10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sigma = 0;
% sub_ind_rate = 0.5;
% 
% all_p = 12:1:13;
% % all_p = 14;
% Num_p = length(all_p);
% 
% 
% all_M = 260;
% Num_M = length(all_M);
% 


%%%%%%%%%%%%%%%%%%%%%%%%%

% sigma = 0;
% sub_ind_rate = 0.5;
% 
% all_p = 3:4;
% Num_p = length(all_p);
% 
% 
% all_M = 80:10:260;
% Num_M = length(all_M);



%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%


RK_est  = cell(Num_p, Num_M, Num_samples);
RK_Info = cell(Num_p, Num_M, Num_samples);


for j = 1:Num_p
    for m = 1:Num_M
        for k = 1:Num_samples

            sysInfo.p = all_p(j);
            sysInfo.M = all_M(m);
            %% Generate data
            [all_rho, trueInfo, observableInfo] = generate_data(sysInfo, 'plotON', 1);
            all_rho = all_rho + randn(size(all_rho))*sigma;

            %% Prepare A and b for matrix sensing
            K = trueInfo.K_true;
            RK = trueInfo.RK_true;
            r = trueInfo.rank_RK_true; 

            % if r >= sysInfo.n^2
            %     r = sysInfo.n^2;
            % end

            RK_sub_blocks = trueInfo.RK_sub_blocks;

            all_rho0    = observableInfo.rho0;
            all_O       = observableInfo.O;

            [A, b] = prepare_A_b_first_row(all_rho0, all_O, all_rho);


            %%
            [RK_est{j, m, k}, RK_Info{j, m, k}] = Learning_quantum_operator(A, b, r, 'Method', 'First_row_subset', 'X_true_sub_blocks', RK_sub_blocks, 'X_true', RK, 'num_retry', 0, 'debugON', 1, 'displayON', 1, 'compute_dnorm', 0, ...
                'ALS_debugON', 1, 'ALS_Acceleration', 'Polyak', 'ALS_beta', 0.4, 'ALS_loss_tol', 1e-7, 'ALS_rel_err_tol', 1e-7, 'sub_ind_ratio', sub_ind_rate, 'ALS_maxiter', 400, 'ALS_loss_plateau', 1e-4);

        end
    end

end
%%




Num_items = 3;
% Num_p = Num_p - 1;
% Pre-allocate a numeric array for all_info
all_info = zeros(Num_p, Num_items, Num_M, Num_samples);


for m = 1:Num_M
    for k = 1:Num_samples
        for l = 1:Num_p
            
            % 1) rel_error_fro_X
            try
                all_info(l, 1, m, k) = RK_Info{l, m, k}.rel_error_fro_X;
            catch
                all_info(l, 1, m, k) = 100;
            end
            
            % 2) time
            try
                all_info(l, 2, m, k) = RK_Info{l, m, k}.time;
            catch
                all_info(l, 2, m, k) = 100;
            end

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

Num_M = length(all_M);
Num_p = length(all_p);

colors(1, :) = color1;
colors(2, :) = color5;
colors(3, :) = color2;
colors(4, :) = color3;
colors(5, :) = color4;
colors(6, :) = color4;

recover_rate = zeros(Num_p, Num_M);
for l = 1:Num_p
    for m = 1:Num_M
        recover_rate(l, m) = sum(squeeze(all_info(l, 1, m, :)) < 1e-5)/Num_samples;
    end
end


%%
figure;grid on
imagesc((all_p), (all_M), recover_rate')


set(gca, 'YDir', 'normal'); % Reverse y-axis to show smallest M at the bottom
xlabel('Dimension of Hilbert space: N')
ylabel('Number of independent trials')

set(gcf, 'Position',  [100, 100, 500, 380]);
set(findall(gcf,'-property','FontSize'),'FontSize',14);
tightfig;
colorbar
colormap(gray);
% saveas(gcf, 'Sec_5_4_2_data_size_rank.pdf')

