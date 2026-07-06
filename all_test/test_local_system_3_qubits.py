# %%
import numpy as np
from qutip import *

# Define number of qubits
num_qubits = 4
N = 2**num_qubits

# Pauli matrices
I = qeye(2)  # Identity
X = sigmax()  # Pauli X
Y = sigmay()  # Pauli Y
Z = sigmaz()  # Pauli Z


# Helper function to generate random Hermitian matrices
def random_hermitian(dim):
    mat = np.random.rand(dim, dim) + 1j * np.random.rand(dim, dim)
    return Qobj((mat + mat.conj().T) / 2)  # Ensure Hermitian

# # Define 2-local Hamiltonian terms
# H_12 = Qobj(tensor(random_hermitian(4), qeye(4)).full().reshape(16, 16))
# H_23 = Qobj(tensor(qeye(2), random_hermitian(4), qeye(2)).full().reshape(16, 16))
# H_34 = Qobj(tensor(qeye(4), random_hermitian(4)).full().reshape(16, 16))
# H_41 = Qobj(np.kron(random_hermitian(4).full(), qeye(4).full()).reshape((16, 16)))

# # Total Hamiltonian (sum of pairwise interactions)
# H_2_local = Qobj(H_12 + H_23 + H_34 + H_41)


def two_qubit_pauli(pauli1, pauli2, qubit1, qubit2, n):
    """Create a 2-local interaction between qubit1 and qubit2 with specified Pauli operators."""
    operators = [I] * n
    operators[qubit1] = pauli1
    operators[qubit2] = pauli2
    return tensor(*operators)

# Pairwise interactions (random coefficients for weighted combinations)
H_12 = (
    np.random.rand() * two_qubit_pauli(X, X, 0, 1, num_qubits)
    # + np.random.rand() * two_qubit_pauli(Y, Y, 0, 1, num_qubits)
    # + np.random.rand() * two_qubit_pauli(Z, Z, 0, 1, num_qubits)
)
H_23 = (
    np.random.rand() * two_qubit_pauli(X, X, 1, 2, num_qubits)
    + np.random.rand() * two_qubit_pauli(Y, Y, 1, 2, num_qubits)
    + np.random.rand() * two_qubit_pauli(Z, Z, 1, 2, num_qubits)
)
H_34 = (
    np.random.rand() * two_qubit_pauli(X, X, 2, 3, num_qubits)
    + np.random.rand() * two_qubit_pauli(Y, Y, 2, 3, num_qubits)
    + np.random.rand() * two_qubit_pauli(Z, Z, 2, 3, num_qubits)
)
H_41 = (
    np.random.rand() * two_qubit_pauli(X, X, 3, 0, num_qubits)
    + np.random.rand() * two_qubit_pauli(Y, Y, 3, 0, num_qubits)
    + np.random.rand() * two_qubit_pauli(Z, Z, 3, 0, num_qubits)
)

# Total Hamiltonian
H_2_local = H_12 + H_23 + H_34 + H_41


# # Define 2-local jump operators
# L_12 = Qobj(tensor(random_hermitian(4), qeye(4)).full().reshape(16, 16))
# L_23 = Qobj(tensor(qeye(2), random_hermitian(4), qeye(2)).full().reshape(16, 16))
# L_34 = Qobj(tensor(qeye(4), random_hermitian(4)).full().reshape(16, 16))
# L_41 = Qobj(np.kron(random_hermitian(4).full(), qeye(4).full()).reshape((16, 16)))

# # Combine jump operators into a list
# collapse_ops = [L_12, L_23, L_34, L_41]

# Pairwise jump operators (random coefficients for Pauli combinations)
L_12 = (
    np.random.rand() * two_qubit_pauli(X, Y, 0, 1, num_qubits)
    + np.random.rand() * two_qubit_pauli(Y, Z, 0, 1, num_qubits)
)
L_23 = (
    np.random.rand() * two_qubit_pauli(Y, X, 1, 2, num_qubits)
    + np.random.rand() * two_qubit_pauli(Z, Z, 1, 2, num_qubits)
)
L_34 = (
    np.random.rand() * two_qubit_pauli(Z, X, 2, 3, num_qubits)
    + np.random.rand() * two_qubit_pauli(X, Y, 2, 3, num_qubits)
)
L_41 = (
    np.random.rand() * two_qubit_pauli(Y, Z, 3, 0, num_qubits)
    + np.random.rand() * two_qubit_pauli(X, X, 3, 0, num_qubits)
)

# Combine jump operators into a list
collapse_ops = [L_12, L_23, L_34, L_41]
# collapse_ops = []

# # Initial state: A density operator on 3 qubits
# rho0 = Qobj(np.random.rand(N, N) + 1j * np.random.rand(N, N))
# rho0 = rho0.dag() @ rho0  # Ensure positivity
# rho0 = rho0 / rho0.tr()   # Normalize

# # Solve the Lindblad master equation
# tlist = np.linspace(0, 10, 100)
# result = mesolve(H_2_local, rho0, tlist, collapse_ops)

# Compute the Liouvillian superoperator
L = liouvillian(H_2_local, collapse_ops)

choi_matrix = to_choi(L).full()
# # Compute the rank of NxN blocks of the Choi matrix
# block_ranks = []
# for i in range(N):
#     for j in range(N):
#         block = choi_matrix[i * N:(i + 1) * N, j * N:(j + 1) * N]
#         rank = np.linalg.matrix_rank(block)
#         block_ranks.append((i, j, rank))

# print(f"Rank of the Choi matrix:" + str(np.linalg.matrix_rank(choi_matrix)))
# # Print the ranks of the NxN blocks
# print("Ranks of NxN blocks of the Choi matrix:")
# for i, j, rank in block_ranks:
#     print(f"Block ({i}, {j}): Rank = {rank}")

np.savetxt("liouvillian_real.csv", np.real(L.full()), delimiter=",")
np.savetxt("liouvillian_imag.csv", np.imag(L.full()), delimiter=",")
np.savetxt("Choi_real.csv", np.real(choi_matrix), delimiter=",")
np.savetxt("Choi_imag.csv", np.imag(choi_matrix), delimiter=",")







import matplotlib.pyplot as plt
import numpy as np


def plot_matrix(matrix, title):
    plt.figure(figsize=(8, 6))
    plt.imshow(matrix, aspect='auto', cmap='viridis')
    plt.colorbar(label='Value')

        # Add grid lines every 64 lines
    num_rows, num_cols = matrix.shape
    for i in range(0, num_rows, 64):
        plt.axhline(i - 0.5, color='white', linestyle='--', linewidth=0.8)
    for j in range(0, num_cols, 64):
        plt.axvline(j - 0.5, color='white', linestyle='--', linewidth=0.8)


    plt.title(title)
    plt.xlabel('Column Index')
    plt.ylabel('Row Index')
    plt.show()



# Plot the Liouvillian matrix (real part)
plot_matrix(np.abs(L.full()), "Liouvillian Matrix (Real Part)")

# Plot the Choi matrix (real part)
plot_matrix(np.abs(choi_matrix), "Choi Matrix (Real Part)")

# Plot the Choi matrix (real part)
plot_matrix(np.abs(H_2_local.full()), "Hamiltonian")

# Plot the Choi matrix (real part)
plot_matrix(np.abs(L_12.full()), "Jumps")

eigenvalues, eigenvectors = np.linalg.eig(L.full())
# Plot an eigenvector matrix of the Liouvillian (real part)
plot_matrix(np.abs(eigenvectors), "First Eigenvector of Liouvillian (Real Part)")


# %%
