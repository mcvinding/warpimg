# WarpIMG
## Introduction

Warp a template MRI anatomy to subject MRI anatomy, in order to create a source space and forward model for MEG source analysis that can be shared without breaking subject confidentiality.  

MRI data, even if defaced, are by nature sensitive information as they depicts the unique anatomical features of the subject. It will therefore require little of any malicious agent who want to uncover the identity of the subject whom the image belong to. Anatomical MRI should therefore not be shared uncritically or without some sort of anatomical masking. On the other hand, the open sharing of scientific data, including neuroimage data, is the cornerstone of open and fair science, so that any researcher can replicate and evaluate the results.

The scripts in this folder is one solution to meet this paradox by providing a pipeline for warping template structural MRI to individual subject structural MRI for creation of source spaces and forward models used in MEG (and EEG - though not validated) source analysis. The warped MRIs can be shared without breaking subject confidentiality while still providing adequate precision for replicating findings obtained when using the original individual subject MRI.

The example scripts present the pipeline implemented in MATAB (www.mathworks.com) using FieldTrip (www.fieldtriptoolbox.org).

## Overview

* 
* 