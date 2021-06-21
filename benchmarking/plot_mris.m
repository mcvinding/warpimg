% MRI plots
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

data_path = '/home/mikkel/mri_warpimg/data/0177';
out_path = '/home/mikkel/mri_warpimg/figures';

%% Load MRI
% Load template MRI
load standard_mri           % Load Colin 27
mri_colin = mri;            % Rename to avoid confusion

load(fullfile(data_path, 'mri_tmp_resliced.mat'));
load(fullfile(data_path, 'mri_org_resliced.mat'));

mri_org_resliced.anatomy(mri_org_resliced.anatomy>5000) = 5000;

%% Plot
cfg = [];
cfg.anaparameter    = 'anatomy';
cfg.method          = 'ortho';
cfg.crosshair       = 'no';
cfg.axis            = 'off';

ft_sourceplot(cfg, mri_tmp_resliced)

ft_sourceplot(cfg, mri_org_resliced)

ft_sourceplot(cfg, mri_colin)

%END