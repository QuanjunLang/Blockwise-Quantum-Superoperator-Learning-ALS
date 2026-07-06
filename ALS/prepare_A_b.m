function [A_mat, b_mat, A, b] = prepare_A_b(all_rho0, all_O, all_rho, operator_option)

[n, ~, N_initial] = size(all_rho0);
N_observable = length(all_O);
[M, ~] = size(all_rho);

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

% for block-wise ALS
A = all_O;
b = zeros(n, M);                % new_b are the measurement result as if we take observables to be E_11, ..., E_1N.
b(1, :) = all_rho(:, 1).';
for i = 1:n-1
    b(i+1, :) = (all_rho(:, n+i) -1i*all_rho(:, 2*n-1+i))-(all_rho(:, 1) + all_rho(:, i+1))*(1 - 1i)/2;
end

%     case 'Channel_first_row_col'
% % For total ALS
%
% A_mat = zeros(n^2, n^2, N_initial*N_observable);
%
% l = 1;
% for m = 1:N_initial
%     rho0 = all_rho0(:, :, m);
%     for k = 1:N_observable
%         O = all_O(:, :, k);
%         A_mat(:, :, l) = kron(conj(O), rho0);
%         l = l+1;
%     end
% end
%
% b_mat = vec(all_rho);
%
% % for block-wise ALS
% A = all_rho0;
% b = zeros(n, M);                % new_b are the measurement result as if we take observables to be E_11, ..., E_1N.
% b(1, :) = all_rho(1, :);
% for i = 1:n-1
%     b(i+1, :) = (all_rho(1+i, :) -1i*all_rho(n+i, :))/2;
% end


% end

end




