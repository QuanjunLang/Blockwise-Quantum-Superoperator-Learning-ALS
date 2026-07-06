K = trueInfo.E_true;
n = sysInfo.n;


all_rho_0 = observableInfo.rho0;
all_rho_1 = observableInfo.all_rho1;
all_O = observableInfo.O;

RK = RR(K);

A = rand(n, n) + 1i*randn(n, n);
B = rand(n, n) + 1i*randn(n, n);

AA = kron(A, B);

norm(RR(AA) - vec(B)*vec(A).')

norm(RR(vec(B)*vec(A).') - kron(A, B))

%%
ind_rho = 2;
ind_O = 2;

P0 = all_rho_0(:, :, ind_rho);
P1 = all_rho_1(:, :, ind_rho);

O = all_O(:, :, ind_O);

output = all_rho(ind_O, ind_rho)

sum(P1'.*O, 'all')

AAA = kron(P0, conj(O));
sum(AAA' .* RK, 'all')


%%
% rho0 = rand(n, n) + 1i*randn(n, n);
k = 1;
l = 2;
rho0 = zeros(n, n);rho0(k, l) = 1;

O = rand(n, n) + 1i*randn(n, n);
O = O + O';

rho1 = reshape(K * vec(rho0), [n, n]);

% rho1_Kraus = zeros(n, n);
% 
% Kraus = trueInfo.Kraus_true;
% for i = 1:trueInfo.rank_RE_true
%     rho1_Kraus = rho1_Kraus + Kraus{i} * rho0 * Kraus{i}';
% end

%1. 
val = sum(conj(rho1) .* O, 'all');
fprintf('<rho1, O> \t\t\t= %f + %f*i\n', real(val), imag(val))

%2. 
val = vec(rho1)'*vec(O);
fprintf("vec(rho1)'*vec(O) \t\t= %f + %f*i\n", real(val), imag(val))

%2. 
val = vec(rho0)'*K'*vec(O);
fprintf("vec(rho0)'mat(K)'*vec(O) \t= %f + %f*i\n", real(val), imag(val))

%2. 
val = sum(conj(K) .* (vec(O)*vec(rho0)'), 'all');
fprintf("<mat(K), vec(O)vec(rho0)'> \t= %f + %f*i\n", real(val), imag(val))

%3. 
val = sum(conj(RK) .* kron(conj(rho0), O), 'all');
fprintf("<RK, conj(rho)*O>  \t\t= %f + %f*i\n", real(val), imag(val))


% 
RK_kl = RK((k-1)*n+1:k*n, (l-1)*n+1:l*n);
RK_lk = RK((l-1)*n+1:l*n, (k-1)*n+1:k*n);

val = sum(conj(RK_kl) .* O, 'all');
fprintf("<RK_kl, O>  \t\t\t= %f + %f*i\n", real(val), imag(val))


val = sum(conj(O) .* RK_lk, 'all');
fprintf("<O, RK_lk>  \t\t\t= %f + %f*i\n", real(val), imag(val))


conj(sum(RK_kl.*O, 'all'))


%%
sum(K' .* (vec(O) * vec(rho0)'), 'all')

vec(rho0)' * K' * vec(O)
vec(rho1)' * vec(O)
sum(conj(rho1) .* O, 'all')