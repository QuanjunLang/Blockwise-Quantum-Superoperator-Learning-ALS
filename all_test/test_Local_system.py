# %%
import numpy as np
from qutip import *

# Define parameters
J12 = 1.0     # Coupling strength between qubits 1 and 2
J34 = 1.0     # Coupling strength between qubits 3 and 4
h1 = 0.5      # Local field on qubit 1
h3 = 0.5      # Local field on qubit 3
gamma12 = 0.1 # Dephasing rate for qubits 1 and 2
kappa34 = 0.2 # Dissipation rate for qubits 3 and 4

# Define Pauli matrices for individual qubits
I = qeye(2)       # Identity matrix for a single qubit
sx = sigmax()     # Pauli X
sz = sigmaz()     # Pauli Z
sm = destroy(2)   # Lowering operator

# Define tensor products for 4 qubits
# Qubit indices: 1, 2, 3, 4
sz1 = tensor(sz, I, I, I)       # σ_z on qubit 1
sz2 = tensor(I, sz, I, I)       # σ_z on qubit 2
sz3 = tensor(I, I, sz, I)       # σ_z on qubit 3
sz4 = tensor(I, I, I, sz)       # σ_z on qubit 4
sx1 = tensor(sx, I, I, I)       # σ_x on qubit 1
sx3 = tensor(I, I, sx, I)       # σ_x on qubit 3
sm3 = tensor(I, I, sm, I)       # Lowering operator on qubit 3
sm4 = tensor(I, I, I, sm.dag()) # Raising operator on qubit 4

# Define the 2-local Hamiltonian
H = J12 * sz1 * sz2 + J34 * sz3 * sz4 + h1 * sx1 + h3 * sx3

# Define jump operators
L1 = np.sqrt(gamma12) * sz1 * sz2  # Dephasing between qubits 1 and 2
L2 = np.sqrt(kappa34) * sm3 * sm4  # Dissipation between qubits 3 and 4

# Define the Lindbladian as a superoperator
dims = [2] * 4  # Dimensions for the 4-qubit system


c_ops_1 = []
superop_1 = liouvillian(H, c_ops_1)
choi_matrix_1 = to_choi(superop_1)

c_ops_2 = [L1, L2]
superop_2 = liouvillian(H, c_ops_2)
choi_matrix_2 = to_choi(superop_2)





# %% Display the Choi matrix
print("Choi Matrix rank:")

print(np.linalg.matrix_rank(choi_matrix.full()))


# Display Choi matrix in blocks
block_size = 16
for i in range(0, choi_matrix.shape[0], block_size):
    for j in range(0, choi_matrix.shape[1], block_size):

        print(f"Block ({i}:{i+block_size}, {j}:{j+block_size}):")
        print(choi_matrix.full()[i:i+block_size, j:j+block_size])
        print(np.linalg.matrix_rank(choi_matrix.full()[i:i+block_size, j:j+block_size]))# %%










# %%
import matplotlib.pyplot as plt

# Plot heatmap of the Choi matrix
plt.figure(figsize=(8, 6))
plt.imshow(np.real(choi_matrix.full()), cmap="viridis", interpolation="nearest")
plt.colorbar(label="Re(Choi Matrix)")
plt.title("Heatmap of Choi Matrix (Real Part)")
plt.xlabel("Matrix Index")
plt.ylabel("Matrix Index")
plt.show()
# %%
# Display Choi matrix in blocks
block_size = 16
for i in range(0, choi_matrix.shape[0], block_size):
    for j in range(0, choi_matrix.shape[1], block_size):

        print(f"Block ({i}:{i+block_size}, {j}:{j+block_size}):")
        # print(choi_matrix.full()[i:i+block_size, j:j+block_size])
        print(np.linalg.matrix_rank(choi_matrix.full()[i:i+block_size, j:j+block_size]))# %%
# %% Save the Choi matrix to a CSV file
import numpy as np

np.savetxt("choi_matrix.csv", choi_matrix.full(), delimiter=",", fmt="%.3f")
print("Choi matrix saved to choi_matrix.csv")
# %%
