%% LCMV virtual channels
%
% <<REF>>
%
% Calculate virtual channels in a set of predefined labels. Estimate
% LCMV beamformer filters from evoked and apply to single trial epochs.

clear all; close all;
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Data paths
data_path = '/home/mikkel/mri_warpimg/data/0177';
ft_path   = '~/fieldtrip/fieldtrip/';
out_folder = '/home/mikkel/mri_warpimg/figures';

%% Load data
fprintf('Loading data... ')
load(fullfile(data_path, 'epo.mat'));

% Read atlas
atlas = ft_read_atlas(fullfile(ft_path, '/template/atlas/aal/ROI_MNI_V4.nii'));

% Load MRI
load(fullfile(data_path,'mri_org_resliced'));
load(fullfile(data_path,'mri_tmp_resliced'));

% Load headmodels and source spaces
load(fullfile(data_path, 'headmodel_org.mat'));
load(fullfile(data_path, 'headmodel_tmp.mat'));
load(fullfile(data_path, 'sourcemodels_mni.mat'));
disp('done')

%% Calculate avg
cfg = [];
evoked = ft_timelockanalysis(cfg, epo);

%% Inspect
% ft_determine_coordsys(mri_org_resliced, 'interactive', 'no'); hold on;
% ft_plot_headmodel(headmodel_org, 'facealpha', 0.25, 'facecolor', 'r')
% ft_plot_mesh(sourcemodel_org.pos(sourcemodel_org.inside,:), 'vertexcolor','b')
% ft_plot_sens(evoked.grad);

%% Add atlas info to sources
load(fullfile(ft_path, 'template/sourcemodel/standard_sourcemodel3d6mm'));
sourcemodel = ft_convert_units(sourcemodel, 'mm');

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

figure;
semilogy(diag(s),'o-');

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

% add atlas
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
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter    = 'tissue';
mri_tst = ft_sourceinterpolate(cfg, source_org, mri_org_resliced);

mri_tst.tissue(~ismember(mri_tst.tissue, labs)) = 0;
mri_tst.tissue(ismember(mri_tst.tissue, labs)) = 1;
mri_tst.tissuelabel = {'ROI'};

cfg = [];
cfg.funparameter = 'tissue';
cfg.anaparameter = 'anatomy';
% cfg.funcolormap  = 'lines';
ft_sourceplot(cfg, mri_tst)

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

%% (re)load
fprintf('Loading... ')
load(fullfile(data_path, 'vrtavg_org.mat'))
load(fullfile(data_path, 'vrtavg_tmp.mat'))
disp('done')

%% Plot
close all

xx = [min(vrtavg_org.time),max(vrtavg_org.time)];
yy = [-8e-10 8e-10];

figure; set(gcf,'Position',[0 0 800 1000]); hold on

subplot(5,2,1); 
plot(vrtavg_org.time, vrtavg_org.avg(1,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(1,:), 'r')
title(vrtavg_org.label(1), 'Interpreter','none'); 
xlim(xx); ylim(yy)

subplot(5,2,2); 
plot(vrtavg_org.time, vrtavg_org.avg(2,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(2,:), 'r')
title(vrtavg_org.label(2), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,3)
plot(vrtavg_org.time, vrtavg_org.avg(5,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(5,:), 'r')
title(vrtavg_org.label(5), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,4)
plot(vrtavg_org.time, vrtavg_org.avg(6,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(6,:), 'r')
title(vrtavg_org.label(6), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,5)
plot(vrtavg_org.time, vrtavg_org.avg(3,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(3,:), 'r')
title(vrtavg_org.label(3), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,6)
plot(vrtavg_org.time, vrtavg_org.avg(4,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(4,:), 'r')
title(vrtavg_org.label(4), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,7)
plot(vrtavg_org.time, vrtavg_org.avg(7,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(7,:), 'r')
title(vrtavg_org.label(7), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,8)
plot(vrtavg_org.time, vrtavg_org.avg(8,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(8,:), 'r')
title(vrtavg_org.label(8), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,9)
plot(vrtavg_org.time, vrtavg_org.avg(9,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(9,:), 'r')
title(vrtavg_org.label(9), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,10)
plot(vrtavg_org.time, vrtavg_org.avg(10,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(10,:), 'r')
title(vrtavg_org.label(10), 'Interpreter','none');
xlim(xx); ylim(yy)

print(fullfile(out_path, 'vrtchanplot.png'), '-dpng')

%END