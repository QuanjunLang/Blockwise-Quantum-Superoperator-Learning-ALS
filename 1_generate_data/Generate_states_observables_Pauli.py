# %%
import numpy as np
import qutip
import warnings
import time
warnings.filterwarnings('ignore')
# rng = np.random.default_rng(12345)
from qutip import sigmax, sigmay, sigmaz, qeye, tensor

# np.random.seed(1)
def test():
    start_time = time.time()

    try:
        M = int(m)
    except NameError:
        M = 17

    try:
        N = int(n)
    except NameError:
        N = 8

    try:
        seed = int(random_seed)
    except NameError:
        seed = 1

    Num_qubits = np.log2(N)
    if Num_qubits == int(Num_qubits):
        Num_qubits = int(Num_qubits)
    else:
        raise ValueError('The dimension of the Hilbert space is not a power of 2.')



    O = generate_pauli_strings(M, Num_qubits)
    rho0 = generate_pauli_strings(M, Num_qubits)

    # Observables
  
    return [np.array([item.full() for item in O]), np.array([item.full() for item in rho0])]


# Function to generate a random Pauli string for 4 qubits
def random_pauli_string(num_qubits=4):
    pauli_ops = [qeye(2), sigmax(), sigmay(), sigmaz()]  # Identity and Pauli operators
    labels = ['I', 'X', 'Y', 'Z']  # Corresponding labels for Pauli operators

    # Generate random indices for Pauli operators
    indices = np.random.randint(0, 4, size=num_qubits)

    # Construct the Pauli string operator
    pauli_string = qutip.Qobj(tensor([pauli_ops[i] for i in indices]).full())

    # Generate the string label
    label = ''.join([labels[i] for i in indices])

    return pauli_string

# Generate 13 random Pauli strings with 4 qubits
def generate_pauli_strings(num_strings=13, num_qubits=4):
    results = []
    # for _ in range(num_strings):
        # temp = random_pauli_string(num_qubits)
        # if temp not in results:
            # results.append(temp)
        # results.append()
    results = [random_pauli_string(num_qubits) for _ in range(num_strings)]
    return results



a = test()
# %%
