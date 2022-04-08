# WarpIMG

## Introduction

Create individualised templte MRI that can be shared without breaking subject confidentiality. Warp a template MRI anatomy to subject MRI anatomy, to create a source space and forward model for MEG source analysis. The procedure is explained in details in the following paper:

> **Vinding, M. C., & Oostenveld, R. (2022). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality. *NeuroImage*, 119165. https://doi.org/10.1016/j.neuroimage.2022.119165**

Please cite the reference above if you use the procedure in your work or want to share/redistribute the example scripts.

## Overview

MRI data, even if defaced, are by nature sensitive information as they depicts the unique anatomical features of the subject. It will therefore require little of any malicious agent who want to uncover the identity of the subject whom the image belong to. Anatomical MRI should therefore not be shared uncritically or without some sort of anatomical masking. On the other hand, the open sharing of scientific data, including neuroimage data, is the cornerstone of open and fair science, so that any researcher can replicate and evaluate the results.

The scripts in this folder is one solution to meet this paradox by providing a pipeline for warping template structural MRI to individual subject structural MRI for creation of source spaces and forward models used in MEG (and EEG - though not validated) source analysis. The warped MRIs can be shared without breaking subject confidentiality while still providing adequate precision for replicating findings obtained when using the original individual subject MRI.

The example scripts present the pipeline implemented in MATLAB (www.mathworks.com) using FieldTrip (www.fieldtriptoolbox.org) and SPM (https://www.fil.ion.ucl.ac.uk/spm/).

## In this folder

* [Example_01_warp_temp2subj](https://github.com/mcvinding/warpimg/blob/main/example_01_warp_temp2subj.m) shows how to create the individualised warped templates.
* [Example_02_create_headmodels](https://github.com/mcvinding/warpimg/blob/main/example_02_create_headmodels.m) show how to use the warped template to create headmodels for MEG source reconstruction.
* [Example_03_create_sourcemodel](https://github.com/mcvinding/warpimg/blob/main/example_03_create_sourcemodel.m) show how to use the warped template to create headmodels for MEG source reconstruction.
* In the foler [benchmarking](https://github.com/mcvinding/warpimg/tree/main/benchmarking), you find the scripts used to compare MEG source reconstruction methods presented in the paper. 
