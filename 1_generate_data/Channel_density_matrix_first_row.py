# %%
import numpy as np
from qutip import Qobj, mesolve, sigmax, Options, rand_herm, rand_super_bcsz, to_kraus, operator_to_vector, vector_to_operator, expect
import qutip
import warnings
import time
from scipy.sparse import csr_matrix
import pandas as pd
from joblib import Parallel, delayed
warnings.filterwarnings('ignore')
rng = np.random.default_rng(12345)

# np.random.seed(1)
def test():
    start_time = time.time()

    try:
        N = int(n)
    except NameError:
        N = 8

    try:
        Kraus_rank = int(p)
    except NameError:
        Kraus_rank = 2
    
    try:
        Num_traj = int(M)
    except NameError:
        Num_traj = 300

    try:
        seed = int(random_seed)
    except NameError:
        seed = 1

    rng = np.random.default_rng(seed)

    # Super operator
    # good condition number
    E = rand_super_bcsz(N, rank=Kraus_rank, seed=rng)
    K = qutip.to_kraus(E)
    Choi = qutip.to_choi(E)

    # bad condition number
    # K_bad = [K[0]]
    # for i in range(1, Kraus_rank):
    #     K_bad.append(qutip.Qobj(K[0].full() + 0.00001*np.random.randn(*np.shape(K[0]))))
    # E = qutip.kraus_to_super(K_bad)
    # Choi = qutip.to_choi(E)
    # K = K_bad
    
    # Using different initial density matrices to observe a given trajectory multiple times
    print('Generate data: first row, col, diagonal density matrices for all trajs')
    # Observables
    rho_D = [generate_dm_diag(N, i) for i in range(0, N)]     # Diagonal parts
    rho_R = [generate_dm_sym(N, 0, i) for i in range(1, N)]   # Real matrices
    rho_I = [generate_dm_asym(N, 0, i) for i in range(1, N)]  # Imaginary matrices

    rho_initial = rho_D + rho_R + rho_I

    # 
    O = [rand_herm(N, density=1, seed=rng) for _ in range(Num_traj)]
    rho_outputs = [vector_to_operator(E * operator_to_vector(rho_0)) for rho_0 in rho_initial]
    result = np.array([[expect(op, rho_1) for op in O] for rho_1 in rho_outputs])

    # t0 = time.time()
    # rho_0 = rho_initial[0]
    # rho_1 =vector_to_operator(E * operator_to_vector(rho_0))
    # expect(O[0], rho_1)
    # t1 = time.time()
    # t = t1 - t0
    # print(t)

    end_time = time.time()
    elapsed_time = end_time - start_time

    # return all_traj, H.full(), [c.full() for c in C], all_initial, elapsed_time, [o.full() for o in O]
    return result, E.full(), Choi.full(), [rho_0.full() for rho_0 in rho_initial], elapsed_time, [o.full() for o in O], np.array([rho1.full() for rho1 in rho_outputs]), [k.full() for k in K]


def generate_dm_sym(N, i, j):
    """
    Generate the quantum state 1/2(E_ij + E_ji + E_ii + E_jj) for a Hilbert space of dimension N.

    Parameters:
        N (int): Dimension of the Hilbert space.
        i (int): Row index (0-based).
        j (int): Column index (0-based).

    Returns:
        Qobj: dm = (E_ij + E_ji + E_ii + E_jj)/2
    """
    # Basis vectors
    ket_i = qutip.basis(N, i)
    ket_j = qutip.basis(N, j)
    
    # E_ij = |i><j| and E_ji = |j><i|
    E_ij = ket_i * ket_j.dag()
    E_ji = ket_j * ket_i.dag()
    E_ii = ket_i * ket_i.dag()
    E_jj = ket_j * ket_j.dag()

    # Symmetric sum
    dm = (E_ij + E_ji + E_ii + E_jj)/2

    return dm
    # # Convert to sparse explicitly (CSR format)
    # sparse_observable = Qobj(csr_matrix(observable.full()), dims=observable.dims, type='csr')
    # return sparse_observable

def generate_dm_asym(N, i, j):
    """
    Generate the quantum state 1/2(E_ij + E_ji + E_ii + E_jj) for a Hilbert space of dimension N.

    Parameters:
        N (int): Dimension of the Hilbert space.
        i (int): Row index (0-based).
        j (int): Column index (0-based).

    Returns:
        Qobj: dm = (E_ij + E_ji + E_ii + E_jj)/2
    """
    # Basis vectors
    ket_i = qutip.basis(N, i)
    ket_j = qutip.basis(N, j)
    
    # E_ij = |i><j| and E_ji = |j><i|
    E_ij = ket_i * ket_j.dag()
    E_ji = ket_j * ket_i.dag()
    E_ii = ket_i * ket_i.dag()
    E_jj = ket_j * ket_j.dag()

    # Symmetric sum
    dm = (1j*E_ij -1j* E_ji + E_ii + E_jj)/2

    return dm
    # # Convert to sparse explicitly (CSR format)
    # sparse_observable = Qobj(csr_matrix(observable.full()), dims=observable.dims, type='csr')
    # return sparse_observable



def generate_dm_diag(N, k):
    """
    Generate the quantum density matrices E_kk for a Hilbert space of dimension N.

    Parameters:
        N (int): Dimension of the Hilbert space.
        k (int): Index for the diagonal element (0-based).

    Returns:
        Qobj: The observable E_kk.
    """
    # Basis vector |k>
    ket_k = qutip.basis(N, k)
    
    # Projector E_kk = |k><k|
    E_kk = ket_k * ket_k.dag()
    # Convert to sparse explicitly (CSR format)
    # sparse_observable = Qobj(csr_matrix(E_kk.full()), dims=E_kk.dims, type='csr')
    # return sparse_observable

    return E_kk


a = test()


# %%
