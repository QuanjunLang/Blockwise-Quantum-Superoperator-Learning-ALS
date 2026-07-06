function [X_est, outputInfo] = Learning_quantum_operator(A, b, r, varargin)
%% parallel_ALS_low_rank
% This function performs parallel reconstruction of low-rank matrices using
% Alternating Least Squares (ALS). The reconstruction is performed for sub-blocks,
% and the results are combined deterministically to form the final estimated matrix.
%
% Inputs:
%   - A: Tensor of size (n, n, d), representing the measurement operator
%   - b: Measurement vector
%   - r: Target rank for reconstruction
%   - varargin: Optional arguments (debugON, plotON, X_true, etc.)
%
% Outputs:
%   - X_est: Reconstructed large matrix
%   - outputInfo: Structure containing reconstruction details (errors, time, etc.)


% copyright - Quanjun Lang, 2024

%% Parse inputs using inputParser
p = inputParser;

% Required inputs
addRequired(p, 'A');
addRequired(p, 'b');
addRequired(p, 'r');

addOptional(p, 'Method', 'First_row_parallel')
% 'First_row'           Joint ALS for the first row
% 'First_row_subset'    Joint ALS for a subset of the first row
% 'First_row_parallel'            Parallel ALS on the blocks of the first row


% Optional arguments with default values
addOptional(p, 'num_retry', 0);                     % Number of retries when ALS does not converge
addOptional(p, 'plotON', 0);
addOptional(p, 'debugON', 0);
addOptional(p, 'displayON', 0);
addOptional(p, 'compute_dnorm', 0);
addOptional(p, 'error_analysis_ON', 1);

addOptional(p, 'X_true', 0);                        % True information to compare error
addOptional(p, 'X_true_sub_blocks', 0);


addOptional(p, 'ALS_Acceleration', 'Nesterov');     % ALS options
addOptional(p, 'ALS_maxiter', 500);     % ALS options
addOptional(p, 'ALS_rel_err_tol', 1e-8);
addOptional(p, 'ALS_loss_tol', 1e-8);
addOptional(p, 'ALS_debugON', 0)
addOptional(p, 'ALS_beta', 0.7)
addOptional(p, 'ALS_loss_plateau', 1e-2)

addOptional(p, 'sub_ind_ratio', 0.1)   % ratio of the sub index

% Parse arguments
parse(p, A, b, r, varargin{:});                     % Extract parsed inputs

Method              = p.Results.Method;

plotON              = p.Results.plotON;
debugON             = p.Results.debugON;
displayON           = p.Results.displayON;
compute_dnorm       = p.Results.compute_dnorm;
num_retry           = p.Results.num_retry;


X_true_sub_blocks   = p.Results.X_true_sub_blocks;
X_true              = p.Results.X_true;


ALS_Acceleration    = p.Results.ALS_Acceleration;
ALS_rel_err_tol     = p.Results.ALS_rel_err_tol;
ALS_loss_tol        = p.Results.ALS_loss_tol;
ALS_debugON         = p.Results.ALS_debugON;
ALS_maxiter         = p.Results.ALS_maxiter;
ALS_beta            = p.Results.ALS_beta;
ALS_loss_plateau    = p.Results.ALS_loss_plateau;

sub_ind_ratio       = p.Results.sub_ind_ratio;      % subset ratio
error_analysis_ON   = p.Results.error_analysis_ON;


%% Extract parameters from input matrices

[~, M] = size(b);                   % Number of observed blocks
[N, ~, ~] = size(A);                % Number of sub-blocks (assumes square structure)
X_est_blocks = cell(N, N);          % Initialize cell array for large matrix blocks
time_counter = tic;                 % Start timer for performance evaluation



% new_b = zeros(N, M);                % new_b are the measurement result as if we take observables to be E_11, ..., E_1N.
% new_b(1, :) = b(1, :);
% for i = 1:N-1
%     new_b(i+1, :) = (b(1+i, :) -1i*b(N+i, :))/2;
% end
% b = b;

%% Reconstruction of the first row

total_iter = num_retry+1;


switch Method
    case 'First_row'
        %% First row Jointly
        fprintf('\nLearning operator from the first row jointly:\n')

        for i = 1:total_iter
            if i > 1
                fprintf('%d-th retry: ', i-1);
            end
            [X_est_first_row, ALS_outputInfo] = ALS_shared_U(A, b, r, 'Acceleration', ALS_Acceleration, ...
                'debugON', ALS_debugON, 'X_true', X_true(1:N, :), 'loss_tol', ALS_loss_tol, 'rel_err_tol', ALS_rel_err_tol, 'maxIter', ALS_maxiter, 'beta', ALS_beta, 'loss_plateau', ALS_loss_plateau);
            flag = ALS_outputInfo.convergence_flag;
            if flag == 1
                break
            end
        end

        if flag ~= 1
            fprintf('Recovery for the first row failed. Please consider generate more data, or increase the retry numbers\n');
            % X_est = [];
            % outputInfo.rel_error_X = 100;
            outputInfo.flag = flag;
            % outputInfo.time = ALS_outputInfo.time;
            % outputInfo.ALS_info = ALS_outputInfo;
            % return
        end



    case 'First_row_subset'
        %% First row subset
        sub_ind = [1; 1+randsample(N-1, floor((N-1)*sub_ind_ratio))];
        fprintf('\nLearning operator using ALS on a length = %d random subset of the first row: ', length(sub_ind))
        fprintf('%d, ', sort(sub_ind))
        fprintf('\n')


        small_b = b(sub_ind, :);
        try
            small_X_true = [X_true_sub_blocks{1, sub_ind}];
        catch ME
            small_X_true = 0;
        end

        for i = 1:total_iter
            if i > 1
                fprintf('%d-th retry: ', i-1);
            end

            [X_est_first_row_small, ALS_outputInfo] = ALS_shared_U(A, small_b, r, 'Acceleration', ALS_Acceleration, ...
                'debugON', ALS_debugON, 'X_true', small_X_true, 'loss_tol', ALS_loss_tol, 'rel_err_tol', ALS_rel_err_tol, 'maxIter', ALS_maxiter, 'beta', ALS_beta, 'loss_plateau', ALS_loss_plateau);
            flag = ALS_outputInfo.convergence_flag;
            if flag == 1
                break
            end
        end

        if flag ~= 1
            fprintf('Recovery for the first row failed. Please consider generate more data, or increase the retry numbers\n');
            % X_est = [];
            % outputInfo.rel_error_X = 100;
            outputInfo.flag = flag;
            % outputInfo.time = ALS_outputInfo.time;
            % outputInfo.ALS_info = ALS_outputInfo;
            % return
        end

        for k = 1:length(sub_ind)
            X_est_blocks{1, sub_ind(k)} = X_est_first_row_small(:, (k-1)*N+1:k*N);
        end


        % Reconstruction of the first row
        U1 = ALS_outputInfo.all_U(:, :, end);

        regmat_V = zeros(M, N*r);
        for m = 1:M
            regmat_V(m, :) = vec(A(:, :, m)' * U1)'; % Matrix product A_i * V
        end

        for k = 1:N
            if ~ any(sub_ind == k)
                b_k = b(k, :).';
                vec_V1 = lsqminnorm(regmat_V, conj(b_k));
                Vk = reshape(vec_V1, [N, r]);
                X_est_blocks{1, k} = U1*Vk';
            end
        end

        X_est_first_row = [X_est_blocks{1, :}];

    case 'First_row_parallel'
        %% First row in parallel

        X_obs_blocks = cell(N, 1);
        ALS_outputInfo = cell(N, 1);
        for k = 1:N
            fprintf('ALS for the (1, %d)-th\t block:', k);


            for i = 1:total_iter
                if i > 1;fprintf('%d-th retry: ', i-1);end

                [X_obs_blocks{k}, ALS_outputInfo{k}] = ALS(A, b(k, :).', r, 'X_true', X_true_sub_blocks{1, k}, ...
                    'Acceleration', ALS_Acceleration, 'loss_tol', ALS_loss_tol, 'rel_err_tol', ALS_rel_err_tol, 'debugON', ALS_debugON, 'maxIter', ALS_maxiter, 'beta', ALS_beta);

                flag = ALS_outputInfo{k}.convergence_flag;
                if flag == 1
                    break
                end
            end


            if flag ~= 1
                fprintf('Recovery for this block failed. Please consider generate more data, or increase the retry numbers\n');
                X_est = [];
                outputInfo.rel_error_fro_X = 100;
                outputInfo.flag = flag;
                outputInfo.time = ALS_outputInfo{k}.time;
                outputInfo.ALS_info = ALS_outputInfo{k};
                return
            end


            X_obs_blocks{k};
        end


        X_est_first_row = [X_obs_blocks{:}];
end

%% Deterministic reconstruction of the large matrix
X_est_blocks = cell(N, N);

X_est_rows = cell(N, 1);
X_est_rows{1} = X_est_first_row;

[~, ~, V] = rsvd(X_est_first_row, r);
V0 = V(:, 1:r);
V0_11 = V(1:N, 1:r);

for k = 2:N
    X_k1 = X_est_first_row(:, (k-1)*N+1:k*N)'; % Diagonal block for the k-th row/column
    C = (pinv(V0_11)*(X_k1'))';
    X_est_rows{k} = C * V0';
end

% Reconstruct the remaining blocks using SVD and basis projections
for k = 1:N
    for l = 1:N
        X_est_blocks{k, l} = X_est_rows{k}(:, (l-1)*N+1:l*N);
    end
end

% Combine sub-blocks into the full reconstructed matrix
X_est = zeros(N^2, N^2);
for i = 1:N
    for j = 1:N
        X_est((i-1)*N+1:i*N, (j-1)*N+1:j*N) = X_est_blocks{i, j};
    end
end




%% Store estimation results
outputInfo.time = toc(time_counter);
outputInfo.ALS_info = ALS_outputInfo;
outputInfo.flag = flag;

outputInfo.X_est_blocks = X_est_blocks;
outputInfo.X_est_first_row_blocks = X_est_first_row;

fprintf('Finished in %.2f seconds \n', outputInfo.time)
%% Error analysis

if error_analysis_ON
    outputInfo = error_analysis(outputInfo, X_est, X_true, 'X_est_blocks', X_est_blocks, 'X_true_sub_blocks', X_true_sub_blocks, 'displayON', displayON, 'compute_dnorm', compute_dnorm);
end

%% Ploting and printing
if outputInfo.flag && debugON && ismatrix(X_true) && plotON
    figure;
    subplot(131)
    % surf(RL_Info.error_blocks);view(0, 90);
    imagesc(outputInfo.error_fro_blocks)
    colorbar
    title('L blocks error')
    subplot(132)
    % surf(RL_Info.rel_error_blocks);view(0, 90);
    imagesc(outputInfo.rel_error_fro_blocks)
    colorbar
    title('L blocks relative error')
    subplot(133)
    % surf(RL_Info.norm_blocks);view(0, 90);
    imagesc(outputInfo.norm_blocks)
    colorbar
    title('L blocks norm')
end

end

