% MRI plots
% 
% Vinding, M. C., & Oostenveld, R. (2022). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality. NeuroImage, 119165. https://doi.org/10.1016/j.neuroimage.2022.119165
%
% Plot the volumes for the original MRI, the warped template, and the
% original Colin. Used in Figure 2.

close all
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Paths
data_path = '~/mri_warpimg/data/0177/170424';
out_path  = '~/mri_warpimg/figures';

%% Load MRI
% Load template MRI
load standard_mri           % Load Colin 27
mri_colin = mri;            % Rename to avoid confusion

load(fullfile(data_path, 'mri_warptmp.mat'));
load(fullfile(data_path, 'mri_org_resliced.mat'));

mri_neuromag_resliced.anatomy(mri_org_resliced.anatomy>5000) = 5000;

%% Plot
cfg = [];
cfg.anaparameter    = 'anatomy';
cfg.method          = 'ortho';
cfg.crosshair       = 'no';
cfg.axis            = 'off';

ft_sourceplot(cfg, mri_warptmp)
print(fullfile(out_path, 'warptmp_image.png'), '-dpng')

ft_sourceplot(cfg, mri_org_resliced)
print(fullfile(out_path, 'org_image.png'), '-dpng')

ft_sourceplot(cfg, mri_colin)
print(fullfile(out_path, 'colin_image.png'), '-dpng')

%END
