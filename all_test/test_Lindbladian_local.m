clc
close all
clear all
rng(0)
addPaths

% copyright  - Quanjun Lang, 2024
%% system settings
pe = pyenv(Version='/opt/anaconda3/bin/python', ExecutionMode = 'OutOfProcess');
terminate(pe)

sysInfo.n               = 16;           %
sysInfo.M               = 1;          % number of independent trajectories
sysInfo.p               = 2;            % number of jumpoperators
%
% sysInfo.operator_option  = 'Channel';
% sysInfo.operator_option  = 'Channel_Pauli';
sysInfo.operator_option  = 'Lindblad';
%% Generate data

[all_rho, trueInfo, observableInfo] = generate_data(sysInfo, 'plotON', 1);


sigma = 0;
all_rho = all_rho + randn(size(all_rho))*sigma;

%% Prepare A and b for matrix sensing
K = trueInfo.K_true;
RK = trueInfo.RK_true;
r = trueInfo.rank_RK_true;
RK_sub_blocks = trueInfo.RK_sub_blocks;

all_rho0    = observableInfo.rho0;
all_O       = observableInfo.O;



%%

liouvillian_real = csvread('liouvillian_real.csv');
liouvillian_imag = csvread('liouvillian_imag.csv');
liouvillian = liouvillian_real + 1i * liouvillian_imag;

L = liouvillian;

choi_real = csvread('choi_real.csv');
choi_imag = csvread('choi_imag.csv');
choi = choi_real + 1i * choi_imag;

C = choi;

[U, S] = eig(L);

s = diag(S);

figure;
subplot(131);imagesc(abs(L));title('Lindbladian')
subplot(132);imagesc(abs(C));title('Choi')
subplot(133);imagesc(abs(U));title('Eigenvectors of Lindbladian')


%%
O = all_rho0(:, :, 1);
% O = all_O(:, :, 2);
rho = all_O(:, :, 1);


c = diag(inv(U) * vec(rho) * vec(O)' * U);
t = 0.1;


figure;
subplot(131);hold on;
plot(abs(c));
plot(abs(c.*exp(s*t)));
legend('coef', 'magnitude of each mode');
subplot(132);hold on;
plot(abs(exp(s*t)));
plot(abs(s))
legend('exponential of modes', 'modes')
subplot(133)
scatter(real(S), imag(s))



%%
L_real = (L + L') / 2; % Dissipative part
L_imag = (L - L') / (2i); % Unitary part (Hamiltonian)


% Define Pauli matrices
I = [1 0; 0 1];
X = [0 1; 1 0];
Y = [0 -1i; 1i 0];
Z = [1 0; 0 -1];

% Store Pauli matrices in a cell array for indexing
pauli_matrices = {I, X, Y, Z};

% Number of qubits
n = 4;

% Generate Pauli basis for n qubits
pauli_basis = cell(4^n, 1);
index = 1;
for i = 1:4
    for j = 1:4
        for k = 1:4
            for l = 1:4
                % Generate tensor product of Pauli matrices
                pauli_basis{index} = kron(kron(kron(pauli_matrices{i}, pauli_matrices{j}), pauli_matrices{k}), pauli_matrices{l});
                index = index + 1;
            end
        end
    end
end



% Project Liouvillian into Pauli basis
coefficients = zeros(length(pauli_basis), length(pauli_basis));
for i = 1:length(pauli_basis)
    for j = 1:length(pauli_basis)
        P1 = pauli_basis{i};
        P2 = pauli_basis{j};
        coefficients(i, j) = vec(P1)' * L * vec(P2);
    end
end

%%

% Create interaction graph
interaction_matrix = abs(coefficients); % Absolute values of coefficients
figure;
imagesc(interaction_matrix);
colorbar;
title('Interaction Strengths in Pauli Basis');
xlabel('Pauli Basis Index');
ylabel('Pauli Basis Index');



% Extract specific pairwise interactions
pairwise_interactions = coefficients(1, 10); % Replace with actual indices
disp('Pairwise Interaction Coefficients:');
disp(pairwise_interactions);


%%
% % Define mapping for Pauli operators
% pauli_map = struct('I', 0, 'X', 1, 'Y', 2, 'Z', 3);
% 
% 
% 
% % Define Pauli operators for n qubits
% n = 4; % Number of qubits
% pauli_ops = {'X', 'I', 'Y'}; % Operators for qubits 1, 2, 3
% 
% % Compute index
% index = 0;
% for qubit = 1:n
%     index = index + 4^(n - qubit) * pauli_map.(pauli_ops{qubit});
% end
% index = index + 1;
% 
% disp(['Index for ', strjoin(pauli_ops, ' ⊗ '), ': ', num2str(index)]);