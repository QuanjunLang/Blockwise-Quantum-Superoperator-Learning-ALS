function [A, b] = get_A_b_FRO_Pauli(sysInfo, observableInfo, RK)

all_O = observableInfo.O;

% Fixed first row Observables
n = sysInfo.n;
M = sysInfo.M;
N_o = 3*n-2;
% all_rho0 = observableInfo.rho0;

random_seed = randi(10000);
a = pyrunfile("Generate_initial_states.py", 'a', n = n, N_o = N_o, random_seed=random_seed);
little_initial_states = double(a);




N_initial = N_o;
N_observable = M;

A = zeros(n^2, n^2, N_initial*N_observable);
b = zeros(M*N_o, 1);


l = 1;
for m = 1:N_initial
    rho0 = squeeze(little_initial_states(m, :, :));
    for k = 1:N_observable
        O = all_O(:, :, k);
        A(:, :, l) = kron(rho0, conj(O));
        b(l) = sum(conj(A(:, :, l)).*RK, 'all');
        l = l+1;
    end
end


end