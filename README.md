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
cvx/               Bundled CVX distribution for diamond-norm calculations
```

## Requirements

### MATLAB

- MATLAB R2023b or newer, because the supplied environment uses Python 3.11.
- Parallel Computing Toolbox is required only for routines using `parfor`.
- CVX is required for diamond-norm calculations. A CVX distribution is
  included in `cvx/`. In particular, the Section 4.1 channel experiment
  sets `dnorm_flag = 1` and therefore requires CVX. Scripts using
  `compute_dnorm = 0` do not require CVX.

The repository includes copies of Tensor Toolbox utilities, randomized SVD,
`superkron`, MATLAB diamond-norm helper code, and CVX. Their original
notices and licenses remain in the corresponding directories.

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

## CVX setup for diamond norms

CVX is a MATLAB dependency and is not installed by `environment.yml`. The
CVX distribution used by this project is included in `cvx/`. From the
repository root, configure it once in MATLAB:

```matlab
repositoryRoot = pwd;
cd(fullfile(repositoryRoot, "cvx"))
cvx_setup
cvx_version
which cvx_begin
cd(repositoryRoot)
```

`which cvx_begin` must return a file inside this repository's `cvx/`
directory. The bundled distribution includes the free SeDuMi and SDPT3
solvers, so a commercial solver is not required for the diamond-norm
calculations used here. CVX remains subject to the license terms provided
in `cvx/LICENSE.txt` and `cvx/GPL.txt`.

The diamond-norm implementation is located at
`util/matlab-diamond-norm-master/src/dnorm.m`. It formulates a semidefinite
program between `cvx_begin` and `cvx_end`; consequently, having `dnorm.m` in
the repository does not remove the external CVX requirement.

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

The experiment scripts and compact data are grouped by manuscript section.
The included `.mat` files contain only the arrays needed for the
corresponding table or figure.

| Result | Plotting or table script | Included data |
|---|---|---|
| Section 4.1 channel tables | `code_for_paper/Sec_4_1/Channel/load_data_make_table.m` | `code_for_paper/Sec_4_1/Channel/4_1_Channel_typical_data*.mat` |
| Section 4.1 Lindbladian tables | `code_for_paper/Sec_4_1/Lindbladian/load_data_make_table.m` | `code_for_paper/Sec_4_1/Lindbladian/4_1_Lindbladian_typical_data*.mat` |
| `Sec_4_2_small_test_rate_channel.pdf` and `Sec_4_2_small_test_time_channel.pdf` | `code_for_paper/Sec_4_2/combine_data_draw_figure.m` | `code_for_paper/Sec_4_2/Channel_Random_all_error.mat` |
| `Sec_4_2_small_test_rate_channel_Pauli.pdf` and `Sec_4_2_small_test_time_channel_Pauli.pdf` | `code_for_paper/Sec_4_2/combine_data_draw_figure.m` | `code_for_paper/Sec_4_2/Channel_Random_Pauli_all_error.mat` |
| `Sec_4_3_error_decay_sub_set_ratio.pdf` | `code_for_paper/Sec_4_3/make_plot.m` | `code_for_paper/Sec_4_3/N_25_M_3000.mat` |
| `Sec_4_4_Necessary_data_size_Hilbert_space.pdf` | `code_for_paper/Sec_4_4/Sec_4_4_Dim_N_M/load_data_plot_figure.m` | `code_for_paper/Sec_4_4/Sec_4_4_Dim_N_M/N_M_change_p_2_recover_rate.mat` |
| `Sec_4_4_Necessary_data_size_rank.pdf` | `code_for_paper/Sec_4_4/Sec_4_4_rank_r_M/combine_data_draw_figure.m` | `code_for_paper/Sec_4_4/Sec_4_4_rank_r_M/p_*.mat` |

For fast reproduction, run the plotting or table script using the included
compact data. For complete reproduction from randomized simulations, run
the corresponding experiment script first. Full simulation runs can be
computationally expensive.

### Diamond-norm experiments

Before running an experiment with either

```matlab
dnorm_flag = 1;
```

or

```matlab
"compute_dnorm", 1
```

verify that CVX is available:

```matlab
assert(exist("cvx_begin", "file") == 2, ...
    "CVX is required for diamond-norm calculations. Run cvx_setup first.");
```

Setting `dnorm_flag = 0` skips the CVX calculation, but scripts that later
read `outputInfo.error_diamond` must also omit the corresponding
diamond-norm table column. Therefore, CVX is required to reproduce tables
or figures that report diamond-norm errors.

## Included data

All compact data required to reproduce the manuscript tables and figures
are included directly in `code_for_paper/`. The data were reduced by saving
only the variables used by the plotting and table scripts rather than
entire MATLAB workspaces.

When generating new results, prefer an explicit variable list:

```matlab
save("figure_data.mat", "all_M", "recover_rate")
```

Avoid saving the complete workspace with `save("figure_data.mat")`, because
intermediate matrices and solver histories can make the file unnecessarily
large.

## Troubleshooting

### `Unrecognized function or variable 'cvx_begin'`

MATLAB found the bundled `dnorm.m`, but the included CVX distribution has
not been configured in the current MATLAB installation. From the repository
root, run:

```matlab
cd cvx
cvx_setup
which cvx_begin
cd ..
```

Then restart the experiment. Do not manually add only selected CVX
subdirectories; the official installer recommends letting `cvx_setup`
configure the complete MATLAB path.

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

The source code and compact processed data required to reproduce all
reported manuscript tables and figures are included in this repository.
The experiment scripts are also provided to regenerate the compact data
from randomized simulations.
