# Data availability

The complete simulation outputs used for the manuscript are approximately
12 GB and are intentionally not stored in this Git repository.

## Processed figure data

Small, figure-ready `.mat` files should be stored in `data/processed/`.
Each file should contain only the arrays required by its corresponding
plotting script, not the complete MATLAB workspace.

The recommended naming convention is:

```text
figure_1_random_pauli.mat
figure_2_channel_lindblad.mat
figure_3_noisy_subset.mat
figure_4_scaling.mat
```

## Complete simulation data

The full simulation outputs will be deposited as a public dataset on
Zenodo. The DOI and archive manifest should be added here after publication.

Recommended archive organization:

```text
Sec_5_1_full_data.zip
Sec_5_2_full_data.zip
Sec_5_3_full_data.zip
Sec_5_4_full_data.zip
DATA_README.md
checksums.txt
```

The Zenodo record should describe the software release, experiment
parameters, random seeds, MATLAB release, and the relationship between each
archive and the manuscript figures.

## Creating compact files

Avoid saving the entire workspace:

```matlab
save("Channel.mat")
```

Instead, explicitly save only variables required by the plotting script:

```matlab
save("figure_2_channel.mat", ...
    "all_M", "recovery_rate", "computation_time");
```

The exact variable list must be taken from the corresponding plotting
script.
