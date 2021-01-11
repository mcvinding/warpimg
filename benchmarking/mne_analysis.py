#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 20 09:47:31 2020. @author: mikkel
"""
import mne


#%% Get data

raw = mne.io.read_raw_fif('/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424/tactile_stim_raw_tsss_mc.fif')

mne.read_epochs_fieldtrip('/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424/cleaned_downsampled_data.mat', info=None)
