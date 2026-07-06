function [A, b] = get_A_b_TRO(sysInfo, RK)


% Fixed first row Observables
n = sysInfo.n;
M = sysInfo.M;
N_o = 3*n-2;


random_seed = randi(10000);
MM = N_o*M;

a = pyrunfile("Generate_states_observables.py", 'a', n = n, m = MM, random_seed=random_seed);
many_random_observables = double(a{1});
many_initial_states = double(a{2});

N_initial = N_o;
N_observable = M;


A = zeros(n^2, n^2, N_initial*N_observable);
b = zeros(N_initial*N_observable, 1);

for l = 1:MM
    rho0 = squeeze(many_initial_states(l, :, :));
    O = squeeze(many_random_observables(l, :, :));
    
    A(:, :, l) = kron(rho0, conj(O));
    b(l) = sum(conj(A(:, :, l)).*RK, 'all');
end

end