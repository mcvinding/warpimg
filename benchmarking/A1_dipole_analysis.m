%% Dipole source analysis
clear all; close all;
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% File paths
data_path  = '/home/mikkel/mri_warpimg/data/0177';

%% Load data
load(fullfile(data_path, 'headmodel_tmp.mat'));
load(fullfile(data_path, 'headmodel_org.mat'));
load(fullfile(data_path, 'evoked.mat'));

%% Plot evoked sensor data
cfg = [];
cfg.layout = 'neuromag306mag.lay';
ft_multiplotER(cfg, evoked);

% cfg = [];
% cfg.viewmode = 'butterfly';
% cfg.channels = 'grad'
% figure; ft_databrowser(cfg, data)

%% Settings
early_latency   = [0.050 0.060]; % s
late_latency    = [0.115 0.155]; % s

%% Do dipole fit: magnetometer fits
cfg = [];
cfg.gridsearch          = 'yes';
cfg.dipfit.metric       = 'rv';
cfg.model               = 'regional';
cfg.channel             = 'megmag';
cfg.nonlinear           = 'yes';
% cfg.dipfit.checkinside  = 'yes';

% FIRST COMPONENT
cfg.latency             = early_latency;
cfg.numdipoles          = 1;
cfg.symmetry            = [];

% template
cfg.headmodel           = headmodel_tmp;
dip_mag_early_tmp = ft_dipolefitting(cfg, evoked);

% orig
cfg.headmodel           = headmodel_org;
dip_mag_early_org = ft_dipolefitting(cfg, evoked);

% SECOND COMPONENT
cfg.latency             = late_latency;
cfg.numdipoles          = 2;                % we expect bilateral activity
cfg.symmetry            = 'x';

% template
cfg.headmodel           = headmodel_tmp;
dip_mag_late_tmp = ft_dipolefitting(cfg, evoked);

% orig
cfg.headmodel       = headmodel_org; 
dip_mag_late_org = ft_dipolefitting(cfg, evoked);

disp('done')

%% Do dipole fit: gradiometer fits
cfg = [];
cfg.gridsearch      = 'yes';            % search the grid for an optimal starting point
cfg.dipfit.metric   = 'rv';             % the metric to minimize (the relative residual variance: proportion of variance left unexplained by the dipole model)
cfg.model           = 'regional';       % assume that the dipole has a fixed position during the time points in the latency range
% cfg.senstype        = 'MEG';            % sensor type
cfg.channel         = 'meggrad';        % which channels to use
cfg.nonlinear       = 'yes';            % do a non-linear search

% FIRST COMPONENT
cfg.latency         = early_latency;    % specify the latency
cfg.numdipoles      = 1;                % we only expect contralateral activity
cfg.symmetry        = [];               % empty for single dipole fit

% template
cfg.headmodel       = headmodel_tmp;
dip_grad_early_tmp = ft_dipolefitting(cfg, evoked);

% orig
cfg.headmodel       = headmodel_org;
dip_grad_early_org = ft_dipolefitting(cfg, evoked);

% SECOND COMPONENT
cfg.latency         = late_latency;
cfg.numdipoles      = 2;                
cfg.symmetry        = 'x';              % bilateral symetry

% template
cfg.headmodel       = headmodel_tmp;
dip_grad_late_tmp = ft_dipolefitting(cfg, evoked);

% original
cfg.headmodel       = headmodel_org;
dip_grad_late_org = ft_dipolefitting(cfg, evoked);

disp('done')

%% Save
fprintf('Saving... ')
save(fullfile(data_path, 'dip_mag_early.mat'),  'dip_mag_early*')
save(fullfile(data_path, 'dip_mag_late.mat'),   'dip_mag_late*')
save(fullfile(data_path, 'dip_grad_early.mat'), 'dip_grad_early*')
save(fullfile(data_path, 'dip_grad_late.mat'),  'dip_grad_late*')
disp('done')

%% Whole window
% GRADS
cfg = [];
cfg.gridsearch     = 'no';
cfg.dipfit.metric  = 'rv';
cfg.model          = 'regional';
cfg.senstype       = 'MEG';
cfg.channel        = 'meggrad';
cfg.nonlinear      = 'no';
cfg.latency        = [0.000; 0.500];

% Original
cfg.headmodel      = headmodel_org; 
cfg.dip.pos        = dip_grad_early_org.dip.pos;
dip_grad_all_org = ft_dipolefitting(cfg, evoked);

% Template
cfg.headmodel           = headmodel_tmp; 
cfg.dip.pos             = dip_grad_early_tmp.dip.pos;
dip_grad_all_tmp = ft_dipolefitting(cfg, evoked);

% Inspect
figure; hold on
plot(dip_grad_all_org.time, sqrt(mean(dip_grad_all_org.dip.mom.^2)))
plot(dip_grad_all_tmp.time, sqrt(mean(dip_grad_all_tmp.dip.mom.^2)))
title('Dipoles gradiometers')

% MAGS
cfg = [];
cfg.gridsearch      = 'no';
cfg.dipfit.metric   = 'rv';
cfg.model           = 'regional';
cfg.senstype        = 'MEG';
cfg.channel         = 'megmag';
cfg.nonlinear       = 'no';
cfg.latency         = [0.000; 0.500];

% Original
cfg.headmodel       = headmodel_org;
cfg.dip.pos         = dip_mag_early_org.dip.pos;
dip_mag_all_org = ft_dipolefitting(cfg, evoked);

% Template
cfg.headmodel       = headmodel_tmp;
cfg.dip.pos         = dip_mag_early_tmp.dip.pos;
dip_mag_all_tmp = ft_dipolefitting(cfg, evoked);

% Inspect
figure; hold on
plot(dip_mag_all_org.time, sqrt(mean(dip_mag_all_org.dip.mom.^2)))
plot(dip_mag_all_tmp.time, sqrt(mean(dip_mag_all_tmp.dip.mom.^2)))
title('Dipoles magnetometers')

%% SAVE
fprintf('Saving... ')
save(fullfile(data_path, 'dip_mag_all.mat'),   'dip_mag_all*')
save(fullfile(data_path, 'dip_grad_all.mat'),  'dip_grad_all*')
disp('done')

%END