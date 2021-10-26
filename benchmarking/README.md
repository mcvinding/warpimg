# Comparing MEG source reconstruction for original MRI and warped template

Compare MEG source reconstruction results using the subject's original MRI and an individualsed warped template. The scripts in this folder where used for the analysis presented in the following paper:

<ref>

Please cite the reference above if you use the procedure in your work or want to share/redistribute the example scripts.
    
The MEG dataset used in the paper to compare source reconstruction methods can be found at: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5053234.svg)](https://doi.org/10.5281/zenodo.5053234)

## In this folder
**Pre-processing**
* `prepare_megdata.m`: Prepare MEG data for source reconstruction.
* `run_freesurfer.sh` : Run Freesurfer procedure on orignal and warped MRI.
* `run_postfreesurfer.sh` : Post-processing of Freeesurfer output to create surface source models.

**MEG source reconstruction**   
* `source_a_dipole.m`: Do dipole fits to evoked response.
* `source_b_dics.m`: DICS source analysis of induced response.
* `source_c_virtualchan.m`: Calculate LCMV "virtual channels" for evoked response.
* `source_d_mne.m`: Minimum-norm estimate of evoked response.
    
**Comparisons**
* `compare_fs_output.m`: Summaries and statistical comparison of morphological features from Freesurfer.
* `compare_source_results.m` : Summaries and statistical comparison of the results of the four types of MEG source reconstruction.
* `compare_volumes.m` : Summaries and statistical of headmodels.

**Create figures**
* `plot_dics.m`: Plot results from DICS source reconstruction.
* `plot_dipoles.m`: Plot results from dipole analysis.
* `plot_erf.m` : Plot MEG sensor evoked response and example topographies.
* `plot_headmodels.m`: Plot the geometry of the headmodels.
* `plot_mne.m`: Plot MNE source reconstructions.
* `plot_mris.m` : Various plots of the MRIs.
* `plot_virtualchan.m`: Plot evoked responses from virtual channels.
