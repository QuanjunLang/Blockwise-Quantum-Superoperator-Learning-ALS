function [all_data, trueInfo, observableInfo] = generate_data(sysInfo, varargin)
% Use Python package to generate trajectories

total_tic = tic;
%% Input parser
p = inputParser;
addRequired(p, 'sysInfo');
addOptional(p, 'plotON', 0);

parse(p, sysInfo, varargin{:});
%% Load parameters

n           = sysInfo.n;
p           = sysInfo.p;
M           = sysInfo.M;

operator_option  = sysInfo.operator_option;

random_seed = randi(10000);
%% Generate data using python packages

switch operator_option
    case 'Channel'
        fprintf('Channel Learning:\n\nData generation,  with N = %d, M = %d and %d Kraus operators, total rank = %d\n', n, M, p, p);
        a = pyrunfile("Channel_density_matrix_first_row.py", 'a', n = n, p = p, M = M, random_seed=random_seed);
    case 'Channel_Pauli'
        fprintf('Channel Learning:\n\nData generation,  with N = %d, M = %d and %d Kraus operators, total rank = %d, using random Pauli observables\n', n, M, p, p);
        a = pyrunfile("Channel_density_matrix_first_row_Pauli.py", 'a', n = n, p = p, M = M, random_seed=random_seed);
    case 'Lindblad'
        fprintf('Lindbladian Learning:\n\nData generation,  with N = %d, M = %d and %d Jump operators, total rank = %d\n', n, M, p, p+2);
        a = pyrunfile("Lindbladian_density_matrix_first_row_finite_difference.py", 'a', n = n, p = p, M = M, random_seed=random_seed);
end

%% Load data from Python code
result_temp     = cell(a);
trueInfo.computation_time = double(result_temp{5});
fprintf('Data generation finished in %.2f seconds\n', trueInfo.computation_time);


K_true          = double(result_temp{2});   % Channel operator
Choi_true       = double(result_temp{3});     % Jump operators

all_rho1        = permute(double(result_temp{7}), [2, 3, 1]);


Kraus_true_temp = cell(result_temp{8});     % Jump operators
Kraus_true      = cell(p, 1);
for i = 1:p
    Kraus_true{i} = double(Kraus_true_temp{i});
end


try all_initial_temp     = cell(result_temp{4});  % Initial
    m = length(all_initial_temp);
    all_initial          = zeros(n, n, m);
    for i = 1:m
        all_initial(:, :, i) = double(all_initial_temp{i});
    end
catch ME
    % Handle the error
    % disp('An error occurred during the conversion:');
    all_initial_temp = double(result_temp{4});
    all_initial = permute(all_initial_temp, [2, 3, 1]);
end

observableInfo.rho0 = all_initial;



% Expectation
all_expect_temp   = double(result_temp{1});
all_data        = permute(all_expect_temp, [2, 1]);

% Observable
O_true_temp     = cell(result_temp{6});
n_o = length(O_true_temp);
O_true          = zeros(n, n, n_o);
for i = 1:n_o
    O_true(:, :, i) = double(O_true_temp{i});
end
observableInfo.O        = O_true;
observableInfo.all_rho1 = all_rho1;




%% Construct the matrix of L and the reshaped one E
trueInfo.K_true = K_true;
trueInfo.RK_true = RR(K_true);

trueInfo.rank_RK_true = rank(trueInfo.RK_true);
trueInfo.Kraus_true = Kraus_true;
trueInfo.Choi_true = Choi_true;
%%
RK = trueInfo.RK_true;

n = sysInfo.n;
% N_o = sysInfo.N_o;

RK_sub_blocks = cell(n, n);
for i = 1:n
    for j = 1:n
        RK_sub_blocks{i, j} = RK((i-1)*n+1:i*n, (j-1)*n+1:j*n);
    end
end

RK_obs_blocks = cell(n_o, 1);
for i = 1:n
    RK_obs_blocks{i} = RK_sub_blocks{i, i};
end

for j = 1:n-1
    RK_obs_blocks{i + j} = RK_sub_blocks{1, j+1} + RK_sub_blocks{j+1, 1};
end

for k = 1:n-1
    RK_obs_blocks{i + j + k} = 1i*RK_sub_blocks{1, k+1} -1i* RK_sub_blocks{k+1, 1};
end

%%
trueInfo.RK_sub_blocks = RK_sub_blocks;
trueInfo.RK_obs_blocks = RK_obs_blocks;

fprintf('Data generation total time: %.2f seconds \n', toc(total_tic));
end





