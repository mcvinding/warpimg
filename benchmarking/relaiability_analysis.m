% Reliability analysis of source reconstructed data using Krippendorff's
% alpha.
addpath('/home/mikkel/reliability_analysis/')

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177';

%% A) Dipole time-series
% Load data
load(fullfile(data_path, 'dip_mag_all.mat'))
load(fullfile(data_path, 'dip_grad_all.mat'))

% Comparison
dat = [sqrt(sum(dip_mag_all_org.dip.mom).^2); sqrt(sum(dip_mag_all_tmp.dip.mom).^2)];
a_mag_all = kripAlphaN2fast(dat);

dat = [sqrt(sum(dip_grad_all_org.dip.mom).^2); sqrt(sum(dip_grad_all_tmp.dip.mom).^2)];
a_grad_all = kripAlphaN2fast(dat);

%% B) DICS source maps
fprintf('Loading data... ')
load(fullfile(data_path, 'dics_contrasts'))
disp('done')

dat = [contrast_org.pow(contrast_org.inside)'; contrast_tmp.pow(contrast_tmp.inside)'];
   
a_dics = kripAlphaN2fast(dat);

%% C) Virtual electrodes



%% D) MNE


