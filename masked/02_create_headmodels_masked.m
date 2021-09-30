%% Create headmodels 
%
% <ref>
%
% Create headmodels (volume conductor models) from anatomical MRIs for MEG 
% source analysis. This is done for the template MRI warped to subject and for
% the original subject MRI for comparison. This script run the process in
% step by step for both the warped template and the orignal MRI to compare
% the results later on.

%% Setup
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Data paths
raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
data_path = '/home/mikkel/mri_warpimg/data/0177';

%% Load MRI
load(fullfile(data_path, 'mri_tmp_resliced2.mat')); % Warped template MRI

%% STEP 1: Segment inner volume of MRI.
cfg = [];
cfg.output = 'brain';
mri_tmp_seg2 = ft_volumesegment(cfg, mri_tmp_resliced2);

% Save (optional)
save(fullfile(data_path, 'mri_tmp_seg2.mat'), 'mri_tmp_seg2')

%% Plot segmentations for inspection
% Plot segmentation for each
load(fullfile(data_path, 'mri_org_seq.mat'))
mri_tmp_seg2.anatomy = mri_tmp_resliced2.anatomy;

cfg = [];
cfg.anaparameter = 'anatomy';
cfg.funparameter = 'brain';
ft_sourceplot(cfg, mri_tmp_seg2);
ft_sourceplot(cfg, mri_org_seg);

% Plot both segmentations on original volume
pltvol = mri_org_resliced;
pltvol.brain = mri_tmp_seg2.brain+mri_org_seg.brain;

cfg.anaparameter = 'anatomy';
cfg.funparameter = 'brain';
ft_sourceplot(cfg, pltvol);

%% STEP 2: Construct mesh from inner volume and create the headmodel
% Step 2A: create 3D brain mesh
cfg = [];
cfg.method      = 'projectmesh';
cfg.tissue      = 'brain';
cfg.numvertices = 3000;
mesh_brain_tmp2 = ft_prepare_mesh(cfg, mri_tmp_seg2);
% mesh_brain_org = ft_prepare_mesh(cfg, mri_org_seg);

% Step 2B: create headmodels
cfg = [];
cfg.method = 'singleshell';
headmodel_tmp2 = ft_prepare_headmodel(cfg, mesh_brain_tmp2);
% headmodel_org = ft_prepare_headmodel(cfg, mesh_brain_org);

% Save headmodels
save(fullfile(data_path, 'headmodel_tmp2.mat'), 'headmodel_tmp2')
% save(fullfile(data_path, 'headmodel_org.mat'), 'headmodel_org')
disp('done')

%% Plot headmodels for inspection
load(fullfile(data_path, 'headshape.mat'))
load(fullfile(data_path, 'grad.mat'))

% Plot alignment with sensors
subplot(1,2,1); hold on
ft_plot_headmodel(headmodel_tmp2, 'edgecolor','b', 'facealpha',0.5)
ft_plot_sens(grad)
ft_plot_headshape(headshape)
title('template')

subplot(1,2,2); hold on
ft_plot_headmodel(headmodel_org, 'edgecolor','r', 'facealpha',0.5)
ft_plot_sens(grad)
ft_plot_headshape(headshape)
title('orig')

% Plot just headmodels
figure; hold on
ft_plot_headmodel(headmodel_tmp2, 'edgecolor','b', 'facealpha',0.5)
ft_plot_headmodel(headmodel_org, 'edgecolor','r', 'facealpha',0.5)

%END