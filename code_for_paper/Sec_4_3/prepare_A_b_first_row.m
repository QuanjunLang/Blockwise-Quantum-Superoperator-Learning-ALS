function [A, b] = prepare_A_b_first_row(all_rho0, all_O, all_rho)

[n, ~, ~] = size(all_rho0);
[M, ~] = size(all_rho);

% for block-wise ALS
A = all_O;
b = zeros(n, M);                % new_b are the measurement result as if we take observables to be E_11, ..., E_1N.
b(1, :) = all_rho(:, 1).';
for i = 1:n-1
    b(i+1, :) = (all_rho(:, n+i) -1i*all_rho(:, 2*n-1+i))-(all_rho(:, 1) + all_rho(:, i+1))*(1 - 1i)/2;
end


end




