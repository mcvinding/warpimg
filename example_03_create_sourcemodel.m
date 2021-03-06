%% Make grid source models
% 
% <<REF>>
%
% Create standard grid source models for volumetric headmodel for orignal
% MRI and warped template. Import standard MNI grid source space and warp
% to orignal MRI and warped template.

addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177';
ft_path   = '/home/mikkel/fieldtrip/fieldtrip'; % this is the path to fieldtrip at Donders

%% Load template
load(fullfile(ft_path, 'template/sourcemodel/standard_sourcemodel3d6mm'));
template_grid = sourcemodel;
template_grid = ft_convert_units(template_grid,'mm');
clear sourcemodel;

%% Load data
% Load headmodel and MRI
fprintf('Loading... ')
load(fullfile(data_path, 'headmodel_tmp.mat'));
load(fullfile(data_path, 'mri_tmp_resliced.mat'));
load(fullfile(data_path, 'headmodel_org.mat'));
load(fullfile(data_path, 'mri_org_resliced.mat'));
disp('done')

%% Make MNI grid sourcemodels
% Take the grid in MNI standard space and warp it to the MRIs.
cfg = [];
cfg.method          = 'basedonmni';
cfg.nonlinear       = 'yes';
cfg.unit            = 'mm';
cfg.template        = template_grid;
cfg.spmversion      = 'spm12';
cfg.spmmethod       = 'new';

% original
cfg.mri             = mri_org_resliced;
cfg.headmodel       = headmodel_org;
sourcemodel_org = ft_prepare_sourcemodel(cfg);

% template
cfg.mri             = mri_tmp_resliced;
cfg.headmodel       = headmodel_tmp;
sourcemodel_tmp = ft_prepare_sourcemodel(cfg);

%% Save
save(fullfile(data_path, 'sourcemodels_mni.mat'), 'sourcemodel_org', 'sourcemodel_tmp')

%% Inspect
figure; hold on; title('Template')
ft_plot_mesh(sourcemodel_tmp.pos(sourcemodel_tmp.inside,:), 'vertexcolor','r');
ft_plot_headmodel(headmodel_tmp, 'facealpha',0.25)
view([1 0 0])

figure; hold on; title('Original')
ft_plot_mesh(sourcemodel_org.pos(sourcemodel_org.inside,:), 'vertexcolor','r');
ft_plot_headmodel(headmodel_org, 'facealpha',0.25)
view([1 0 0])

%% Make standard grid sourcemodels
% Without any normalization. All coordinates are in MRI native space.
cfg = [];
cfg.method          = 'basedonresolution';
cfg.unit            = 'mm';
cfg.resolution      = 6;
cfg.xgrid           = 'auto';
cfg.ygrid           = 'auto';
cfg.zgrid           = 'auto';

% orig
cfg.mri             = mri_org_resliced;
cfg.headmodel       = headmodel_org;
srcmodel_org  = ft_prepare_sourcemodel(cfg);

% template
cfg.mri             = mri_tmp_resliced;
cfg.headmodel       = headmodel_tmp;
srcmodel_tmp = ft_prepare_sourcemodel(cfg);

%% Inspect
figure; hold on; title('Template')
ft_plot_mesh(srcmodel_tmp.pos(srcmodel_tmp.inside,:), 'vertexcolor','r');
ft_plot_headmodel(headmodel_tmp, 'facealpha',0.25)
view([1 0 0])

figure; hold on; title('Original')
ft_plot_mesh(srcmodel_org.pos(srcmodel_org.inside,:), 'vertexcolor','r');
ft_plot_headmodel(headmodel_org, 'facealpha',0.25)
view([1 0 0])

%% Save
save(fullfile(data_path, 'sourcemodels_grd.mat'), 'srcmodel_org', 'srcmodel_tmp')

%END