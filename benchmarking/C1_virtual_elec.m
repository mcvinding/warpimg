% LCMV virtual channels
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults 

%% Compute paths
raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
data_path = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Load data
fprintf('Loading... ')
% load(fullfile(raw_folder, 'baseline_data.mat'))
load(fullfile(raw_folder, 'cleaned_downsampled_data.mat'))
disp('done')

cfg = [];
cfg.trials = cleaned_downsampled_data.trialinfo==8;
data = ft_selectdata(cfg, cleaned_downsampled_data);

%% Prepare data
cfg = [];
cfg.channel = 'MEG';
cfg.latency = [-0.2 1.1];
data_slct = ft_selectdata(cfg, data);

cfg = [];
cfg.demean = 'yes';
cfg.baselinewindow = [-inf 0];
data_bs = ft_preprocessing(cfg, data_slct);

evoked = ft_timelockanalysis([], data_bs);

%% Read atlas
load(fullfile(data_path,'mri_neuromag_resliced'));
atlas = ft_read_atlas('/home/mikkel/fieldtrip/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
% 
% atlas = ft_read_atlas('~/fieldtrip/fieldtrip/template/atlas/afni/TTatlas+tlrc.HEAD')
% 
% atlas = ft_read_atlas('/home/mikkel/fieldtrip/fieldtrip/template/atlas/spm_anatomy/AllAreas_v17_MPM.mat')

atlas_nmg = ft_convert_coordsys(atlas, 'neuromag', 0, mri_neuromag_resliced);

%% Load headmodels and source spaces
load(fullfile(data_path, 'headmodel_org.mat'));
load(fullfile(data_path, 'headmodel_tmp.mat'));

load(fullfile(data_path, 'sourcemodels.mat'));

%% Make leadfields
cfg = [];
cfg.grad            = evoked.grad;    % magnetometer and gradiometer specification
cfg.channel         = 'meg';
cfg.senstype        = 'meg';

cfg.sourcemodel     = sourcemodel_orig;
cfg.headmodel       = headmodel_org;

leadfield_org = ft_prepare_leadfield(cfg);

cfg.sourcemodel     = sourcemodel_tmp;
cfg.headmodel       = headmodel_tmp;
leadfield_tmp = ft_prepare_leadfield(cfg);

%% Make filter
% Calculate covariance
cfg = [];
cfg.covariance          = 'yes';
cfg.covariancewindow    = 'all';
cfg.channel             = 'MEG';
data_cov = ft_timelockanalysis(cfg, evoked);

[u,s,v] = svd(data_cov.cov);
d       = -diff(log10(diag(s)));
d       = d./std(d);
kappa   = find(d>5,1,'first');

% fprintf('Kappa = %i\n', kappa)

% Do source analysis
cfg = [];
cfg.method              = 'lcmv';
cfg.lcmv.kappa          = kappa;
cfg.lcmv.keepfilter     = 'yes';
cfg.lcmv.fixedori       = 'no';
cfg.lcmv.weightnorm     = 'unitnoisegain';
cfg.lcmv.projectnoise   = 'yes';

cfg.channel             = 'MEG';
cfg.senstype            = 'MEG';
cfg.headmodel           = headmodel_org;
cfg.sourcemodel         = leadfield_org;

source_org = ft_sourceanalysis(cfg, evoked);

cfg.headmodel           = headmodel_tmp;
cfg.sourcemodel         = leadfield_tmp;

source_tmp = ft_sourceanalysis(cfg, evoked);

%% Interpolate atlas
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter    = 'tissue';

atlas_org = ft_sourceinterpolate(cfg, atlas_nmg, source_org);
atlas_org.pos = source_org.pos;

atlas_tmp = ft_sourceinterpolate(cfg, atlas_nmg, source_tmp);
atlas_tmp.pos = source_tmp.pos;

% TEST
load(fullfile(data_path,'mri_tmp_resliced'));

cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter    = 'tissue';
mri_tst = ft_sourceinterpolate(cfg, atlas_tmp, mri_tmp_resliced);

cfg = [];
cfg.funparameter = 'tissue';
% cfg.downsample = 2;
ft_sourceplot(cfg, mri_tst)

%% Make virtual channel
cfg = [];
cfg.parcellation = 'tissue';
cfg.parcel       = {'Precentral_R', 'Precentral_L'};
% cfg.method       = 'eig'
vrtchannls_org = ft_virtualchannel(cfg, data_bs, source_org, atlas_org);
vrtchannls_tmp = ft_virtualchannel(cfg, data_bs, source_tmp, atlas_tmp);

% Average
vrtavg_org = ft_timelockanalysis([], vrtchannls_org);
vrtavg_tmp = ft_timelockanalysis([], vrtchannls_tmp);

%% Plot
subplot(2,2,1); 
plot(vrtavg_org.time, vrtavg_org.avg(1,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(1,:), 'r')
title('Left precentral ROI'); xlim([min(vrtavg_org.time),max(vrtavg_org.time)])
subplot(2,2,2); 
plot(vrtavg_org.time, vrtavg_org.avg(2,:), 'b'); hold on
plot(vrtavg_tmp.time, vrtavg_tmp.avg(2,:), 'r')
title('Right precentral ROI'); xlim([min(vrtavg_org.time),max(vrtavg_org.time)])

subplot(2,2,3)
scatter(vrtavg_org.avg(1,:), vrtavg_tmp.avg(1,:), 'k')

subplot(2,2,4)
scatter(vrtavg_org.avg(2,:), vrtavg_tmp.avg(2,:), 'k')

corr(vrtavg_org.avg(1,:)', vrtavg_tmp.avg(1,:)')
corr(vrtavg_org.avg(2,:)', vrtavg_tmp.avg(2,:)')

%% Kripps
% addpath
















