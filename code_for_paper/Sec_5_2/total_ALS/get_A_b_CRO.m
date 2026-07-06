function [A, b] = get_A_b_CRO(sysInfo, observableInfo, RK)

all_O = observableInfo.O;
% Fixed first row Observables
n = sysInfo.n;
M = sysInfo.M;
N_o = 3*n-2;
% all_rho0 = observableInfo.rho0;


random_seed = randi(10000);
a = pyrunfile("Generate_initial_states.py", 'a', n = n, N_o = N_o*M, random_seed=random_seed);
many_random_initial_states = double(a);

N_initial = N_o;
N_observable = M;

A = zeros(n^2, n^2, N_initial*N_observable);
b = zeros(N_initial*N_observable, 1);

l = 1;
for k = 1:N_observable
    for m = 1:N_initial
        rho0 = squeeze(many_random_initial_states(l, :, :));

        O = all_O(:, :, k);
        
        A(:, :, l) = kron(rho0, conj(O));
        b(l) = sum(conj(A(:, :, l)).*RK, 'all');
        l = l+1;
    end
end


end