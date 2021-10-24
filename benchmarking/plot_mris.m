% MRI plots
% 
% <<REF>>
%
% Plot the volumes for the original MRI, the warped template, and the
% original Colin. Used in Figure 1.
close all
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177/170424';
out_path  = '/home/mikkel/mri_warpimg/figures';

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