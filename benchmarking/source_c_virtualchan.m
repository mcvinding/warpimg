%% LCMV virtual channels
%
% Vinding, M. C., & Oostenveld, R. (2022). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality. NeuroImage, 119165. https://doi.org/10.1016/j.neuroimage.2022.119165
%
% Calculate virtual channels in a set of predefined labels. Estimate
% LCMV beamformer filters from evoked and apply to single trial epochs.

clear all; close all;

%% Data paths
data_path = '~/mri_warpimg/data/0177/170424';
ft_path   = '~/fieldtrip/fieldtrip/';
addpath(ft_path);
ft_defaults

%% Load data
fprintf('Loading data... ')
load(fullfile(data_path, 'epo.mat'));
load(fullfile(data_path, 'evoked.mat'));

% Read atlas
atlas = ft_read_atlas(fullfile(ft_path, '/template/atlas/aal/ROI_MNI_V4.nii'));

% Load MRI
load(fullfile(data_path, 'mri_org_resliced'));
load(fullfile(data_path, 'mri_warptmp'));

% Load headmodels and source spaces
load(fullfile(data_path, 'headmodel_org.mat'));
load(fullfile(data_path, 'headmodel_tmp.mat'));
load(fullfile(data_path, 'sourcemodels_mni.mat'));
disp('done')

%% Units
headmodel_org = ft_convert_units(headmodel_org, 'm');
headmodel_tmp = ft_convert_units(headmodel_tmp, 'm');
sourcemodel_org = ft_convert_units(sourcemodel_org, 'm');
sourcemodel_tmp = ft_convert_units(sourcemodel_tmp, 'm');

%% Add atlas info to sources
load(fullfile(ft_path, 'template/sourcemodel/standard_sourcemodel3d6mm'));
sourcemodel = ft_convert_units(sourcemodel, 'cm');

cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter    = 'tissue';
tmp = ft_sourceinterpolate(cfg, atlas, sourcemodel);
tmp.tissuelabel = atlas.tissuelabel;

atlas_grid = ft_checkdata(tmp, 'datatype', 'source');
atlas_grid.inside = sourcemodel.inside;

%% Make leadfields
cfg = [];
cfg.grad            = evoked.grad;    % magnetometer and gradiometer specification
cfg.channel         = 'meg';
cfg.senstype        = 'meg';
cfg.normalize       = 'yes';
cfg.reducerank      = 2;

% Original
cfg.sourcemodel     = sourcemodel_org;
cfg.headmodel       = headmodel_org;
leadfield_org = ft_prepare_leadfield(cfg);

% Template
cfg.sourcemodel     = sourcemodel_tmp;
cfg.headmodel       = headmodel_tmp;
leadfield_tmp = ft_prepare_leadfield(cfg);

%% Calculate Kappa
cfg = [];
cfg.covariance          = 'yes';
cfg.covariancewindow    = 'all';
cfg.channel             = 'MEG';
data_cov = ft_timelockanalysis(cfg, epo);

[u,s,v] = svd(data_cov.cov);
d       = -diff(log10(diag(s)));
d       = d./std(d);
kappa   = find(d>5,1,'first');
fprintf('Kappa = %i\n', kappa)

% figure;
% semilogy(diag(s),'o-');

%% Do initial source analysis to calculte filters
cfg = [];
cfg.method              = 'lcmv';
cfg.channel             = 'meg';
cfg.lcmv.keepfilter     = 'yes';
cfg.lcmv.fixedori       = 'yes';
cfg.lcmv.lambda         = '5%';
cfg.lcmv.kappa          = kappa;
cfg.lcmv.projectmom     = 'yes';

% Original
cfg.headmodel           = headmodel_org;
cfg.sourcemodel         = leadfield_org;
source_org = ft_sourceanalysis(cfg, data_cov);

% Template
cfg.headmodel           = headmodel_tmp;
cfg.sourcemodel         = leadfield_tmp;
source_tmp = ft_sourceanalysis(cfg, data_cov);

%% add atlas
source_org.tissue = atlas_grid.tissue;
source_org.tissuelabel = atlas_grid.tissuelabel;
source_tmp.tissue = atlas_grid.tissue;
source_tmp.tissuelabel = atlas_grid.tissuelabel;

%% Find some fun labels
find(~cellfun(@isempty, strfind(atlas_grid.tissuelabel, 'Postcentral')))
find(~cellfun(@isempty, strfind(atlas_grid.tissuelabel, 'Thalamus')))
find(~cellfun(@isempty, strfind(atlas_grid.tissuelabel, 'Cerebellum_4_5')))

labs = [1, 2, 13, 14, 57, 58, 77, 78, 97, 98]; % Manually found labels
atlas_grid.tissuelabel(labs)

%% Plot for inspection
% cfg = [];
% cfg.interpmethod = 'nearest';
% cfg.parameter    = 'pow';
% mri_tst = ft_sourceinterpolate(cfg, source_org, mri_org_resliced);
% 
% mri_tst.tissue(~ismember(mri_tst.tissue, labs)) = 0;
% mri_tst.tissue(ismember(mri_tst.tissue, labs)) = 1;
% mri_tst.tissuelabel = {'ROI'};
% 
% cfg = [];
% cfg.funparameter = 'tissue';
% cfg.anaparameter = 'anatomy';
% ft_sourceplot(cfg, mri_tst)

%% Make virtual channel
cfg = [];
cfg.parcellation = 'tissue';
cfg.parcel       = source_org.tissuelabel(labs);    %{'Precentral_L', 'Precentral_R'};
cfg.method       = 'svd';
vrtchannls_org = ft_virtualchannel(cfg, epo, source_org);
vrtchannls_tmp = ft_virtualchannel(cfg, epo, source_tmp);

% Average
vrtavg_org = ft_timelockanalysis([], vrtchannls_org);
vrtavg_tmp = ft_timelockanalysis([], vrtchannls_tmp);

%% Save
fprintf('Saving... ')
save(fullfile(data_path, 'vrtavg_org.mat'), 'vrtavg_org')
save(fullfile(data_path, 'vrtavg_tmp.mat'), 'vrtavg_tmp')
disp('done')

%END
