# Blockwise Quantum Superoperator Learning with ALS

MATLAB and Python code for learning low-rank quantum channels and
Lindbladians via randomized and blockwise matrix sensing, with accelerated
alternating least-squares (ALS) solvers and numerical experiments associated
with:

> Quanjun Lang and Jianfeng Lu,  
> [A Unified Blockwise Measurement Design for Learning Quantum Channels and Lindbladians via Low-Rank Matrix Sensing](https://arxiv.org/abs/2501.14080),  
> arXiv:2501.14080.

## Overview

The repository contains:

- random and blockwise measurement designs for quantum superoperators;
- data-generation routines for quantum channels and Lindbladians;
- total, parallel, joint, and subset ALS implementations;
- accelerated ALS variants;
- scripts used for the numerical experiments in the paper.

The code uses MATLAB for matrix sensing and optimization and Python/QuTiP
for quantum data generation.

## Repository layout

```text
1_generate_data/   Python and MATLAB data-generation routines
ALS/               ALS reconstruction algorithms
code_for_paper/    Experiment and plotting scripts used in the paper
all_test/          Development and consistency checks
util/              Bundled numerical utilities
addPaths.m         Adds repository code to the MATLAB path
main.m             Small channel-learning example
environment.yml    Reproducible Python environment
setup_python.m     Portable MATLAB-to-Python configuration
data/              Data documentation and compact figure data
```

## Requirements

### MATLAB

- MATLAB R2023b or newer, because the supplied environment uses Python 3.11.
- Parallel Computing Toolbox is required only for routines using `parfor`.
- CVX is optional and is required only when diamond-norm calculations are
  enabled. The examples disable them by default with `compute_dnorm = 0`.

The repository includes copies of Tensor Toolbox utilities, randomized SVD,
`superkron`, and MATLAB diamond-norm helper code. Their original notices and
licenses remain in the corresponding `util/` directories.

### Python

The reproducibility environment pins:

- Python 3.11
- NumPy 1.26.4
- SciPy 1.17.1
- QuTiP 5.2.3
- pandas 3.0.3
- joblib 1.5.3
- Matplotlib 3.11.0

NumPy is pinned below version 2 because older binary builds of QuTiP are not
compatible with the NumPy 2 ABI. QuTiP is pinned to 5.2.3 because the source
imports the backward-compatible `qutip.Options` symbol.

## Python environment setup

Install Miniconda, Anaconda, or another Conda-compatible distribution. From
the repository root, run:

```bash
conda env create -f environment.yml
conda activate blockwise-quantum-superoperator-learning-als
```

Verify the required imports:

```bash
python -c "import numpy, scipy, qutip, pandas, joblib, matplotlib; from qutip import Options; print('NumPy', numpy.__version__); print('QuTiP', qutip.__version__)"
```

Find the environment's Python executable:

```bash
python -c "import sys; print(sys.executable)"
```

Set that path before starting MATLAB:

```bash
export QUANTUM_ALS_PYTHON="$CONDA_PREFIX/bin/python"
```

On Windows PowerShell:

```powershell
$env:QUANTUM_ALS_PYTHON = "$env:CONDA_PREFIX\python.exe"
```

Alternatively, set it inside MATLAB:

```matlab
setenv("QUANTUM_ALS_PYTHON", ...
    "/path/to/blockwise-quantum-superoperator-learning-als/bin/python");
```

Then configure Python from MATLAB:

```matlab
addPaths
pe = setup_python();
disp(pe)
pyrun("import numpy, qutip; print(numpy.__version__, qutip.__version__)")
```

The displayed executable must belong to
`blockwise-quantum-superoperator-learning-als`, not the base Conda
environment.

## Quick start

Start MATLAB in the repository root and run:

```matlab
addPaths
pe = setup_python();
main
```

`main.m` demonstrates channel learning with:

- Hilbert-space dimension `N = 10`;
- `M = 80` observable settings;
- two Kraus operators;
- total, joint, subset, and parallel ALS variants.

Some existing experiment scripts still contain a machine-specific call such
as:

```matlab
pe = pyenv(Version="/opt/anaconda3/bin/python", ...
    ExecutionMode="OutOfProcess");
```

For portability, replace that block with:

```matlab
pe = setup_python();
```

Do not commit a personal Python path.

## Reproducing the paper figures

The experiment scripts are grouped by manuscript section:

| Output | Primary script |
|---|---|
| `Sec_5_2_small_test_rate_channel.pdf` | `code_for_paper/Sec_5_2/Sec_5_2_1_small_channel_random_Pauli/Sec_5_2_2_all_four_ALS_new.m` |
| `Sec_5_2_small_test_rate_channel_Pauli.pdf` | `code_for_paper/Sec_5_2/Sec_5_2_1_small_channel_random_Pauli/Sec_5_2_2_all_four_ALS_new_Pauli.m` |
| `Sec_5_2_fast_ALS_rate_all.pdf` and `Sec_5_2_fast_ALS_time_all.pdf` | `code_for_paper/Sec_5_2/Sec_5_2_2_large_channel_Lindbladian/combine_data_draw_figure.m` |
| `Sec_5_3_error_decay_sub_set_ratio.pdf` | `code_for_paper/Sec_5_3/Sec_5_3_convergence_with_M_noisy.m` and `make_plot.m` |
| `Sec_5_4_Necessary_data_size_Hilbert_space.pdf` | `code_for_paper/Sec_5_4/Sec_5_4_1/Sec_5_4_efficient_sample_size.m` |
| `Sec_5_4_Necessary_data_size_rank.pdf` | `code_for_paper/Sec_5_4/Sec_5_4_2/combine_data_draw_figure_computation_time.m` |

Two reproduction workflows are planned:

1. **Figure reproduction:** load compact processed data from
   `data/processed/` and run the plotting scripts.
2. **Complete reproduction:** regenerate the simulation outputs and then run
   the plotting scripts. This is substantially more computationally
   expensive.

## Large data

The complete simulation outputs are approximately 12 GB. They are excluded
from Git and will be deposited on Zenodo as a versioned dataset with a DOI.
Small processed arrays needed to redraw the figures should remain in
`data/processed/`.

See [`data/README.md`](data/README.md) for the proposed archive organization
and compact-data policy.

## Citation

If this repository is useful in your work, please cite:

```bibtex
@article{lang2025unified,
  title   = {A Unified Blockwise Measurement Design for Learning Quantum
             Channels and Lindbladians via Low-Rank Matrix Sensing},
  author  = {Lang, Quanjun and Lu, Jianfeng},
  journal = {arXiv preprint arXiv:2501.14080},
  year    = {2025},
  doi     = {10.48550/arXiv.2501.14080}
}
```

## Data and code availability

The source code and compact processed data required to reproduce the
manuscript figures will be maintained in this repository. The complete
simulation outputs will be archived separately on Zenodo because of their
size. The Zenodo DOI will be added after the dataset is published.
