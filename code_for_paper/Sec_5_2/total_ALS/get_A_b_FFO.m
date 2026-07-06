function [A_mat, b_mat] = get_A_b_FFO(sysInfo, observableInfo, all_rho)

all_rho0 = observableInfo.rho0;
all_O = observableInfo.O;

[n, ~, N_initial] = size(all_rho0);
[~, ~, N_observable] = size(all_O);
% [M, ~] = size(all_rho);

% switch operator_option


% case {'Channel', 'Lindblad'}
% For total ALS

A_mat = zeros(n^2, n^2, N_initial*N_observable);

l = 1;
for m = 1:N_initial
    rho0 = all_rho0(:, :, m);
    for k = 1:N_observable
        O = all_O(:, :, k);
        A_mat(:, :, l) = kron(conj(rho0), O);
        l = l+1;
    end
end

b_mat = vec(all_rho);

end