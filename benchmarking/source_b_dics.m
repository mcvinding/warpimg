%% DICS source reconstruction of beta desync.
% 
% <<REF>>
%
% Do DICS source reconstruction of beta desynchronization. Calucalte CSD in
% betadeysnchronization and similar length baseline period. Calculate
% beamformer filter for both periods and apply filters to data. Calcualte
% activation power between desync and baseline periodes.

close all; clear all
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Compute paths
data_path = '/home/mikkel/mri_warpimg/data/0177';

%% Load data
fprintf('Loading... ')
load(fullfile(data_path, 'data.mat'))
disp('done')

%% Select MEG data (beta desynchroinisation window and appropiate baseline)
desync_toi   = [0.220 0.500];
baseline_toi = [-0.500 -0.220];

% Define segments
cfg = [];
cfg.toilim = desync_toi;
tois_desync = ft_redefinetrial(cfg, data);

cfg.toilim = baseline_toi;
tois_baseline = ft_redefinetrial(cfg, data);

tois_combined = ft_appenddata(cfg, tois_desync, tois_baseline);

%% Calculate CSD;
cfg = [];
cfg.method     = 'mtmfft';
cfg.output     = 'powandcsd';
cfg.taper      = 'hanning';
cfg.channel    = 'meg';
cfg.foilim     = [20 20];
cfg.keeptrials = 'no';
cfg.pad        = 'nextpow2';

pow_desync   = ft_freqanalysis(cfg, tois_desync);
pow_baseline = ft_freqanalysis(cfg, tois_baseline);
pow_combined = ft_freqanalysis(cfg, tois_combined);

%% Load headmodels and source spaces
fprintf('Loading... ')
load(fullfile(data_path, 'headmodel_org.mat'));
load(fullfile(data_path, 'headmodel_tmp.mat'));
load(fullfile(data_path, 'sourcemodels_mni.mat'));
disp('done')

%% Inspect
% ft_determine_coordsys(mri_tmp_resliced, 'interactive', 'no'); hold on;
% ft_plot_sens(data.grad, 'unit', 'mm');
% ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
% ft_plot_mesh(sourcemodel_org, 'vertexcolor','b')

%% Make leadfields
cfg = [];
cfg.grad            = pow_combined.grad;    % magnetometer and gradiometer specification
cfg.channel         = 'meg';
cfg.senstype        = 'meg';

cfg.sourcemodel     = sourcemodel_org;
cfg.headmodel       = headmodel_org;

leadfield_org = ft_prepare_leadfield(cfg);

cfg.sourcemodel     = sourcemodel_tmp;
cfg.headmodel       = headmodel_tmp;
leadfield_tmp = ft_prepare_leadfield(cfg);

%% DICS
cfg = [];
cfg.method              = 'dics';
cfg.frequency           = pow_combined.freq;
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
cfg.dics.keepfilter     = 'yes';
cfg.dics.realfilter     = 'yes'; 
cfg.channel             = 'meg'; 
cfg.grad                = pow_combined.grad;

% Original
cfg.sourcemodel         = leadfield_org;
cfg.headmodel           = headmodel_org;
dics_combined_org = ft_sourceanalysis(cfg, pow_combined);   

cfg.sourcemodel.filter = dics_combined_org.avg.filter;    
dics_desy_org = ft_sourceanalysis(cfg, pow_desync);
dics_base_org = ft_sourceanalysis(cfg, pow_baseline);    

% Template
cfg.sourcemodel         = leadfield_tmp;
cfg.headmodel           = headmodel_tmp;
dics_combined_tmp = ft_sourceanalysis(cfg, pow_combined);

cfg.sourcemodel.filter = dics_combined_tmp.avg.filter; 
dics_desy_tmp = ft_sourceanalysis(cfg, pow_desync);
dics_base_tmp = ft_sourceanalysis(cfg, pow_baseline);
    
%% Save
fprintf('Saving... ')
save(fullfile(data_path, 'dics_org'), 'dics_desy_org', 'dics_base_org');
save(fullfile(data_path, 'dics_tmp'), 'dics_desy_tmp', 'dics_base_tmp');
disp('done')

%% Contrast
cfg = [];
cfg.operation   = '(x1-x2)/(x1+x2)';
cfg.parameter   = 'pow';
contrast_org = ft_math(cfg, dics_desy_org, dics_base_org);
contrast_tmp = ft_math(cfg, dics_desy_tmp, dics_base_tmp);

%% Save
fprintf('Saving... ')
save(fullfile(data_path, 'dics_contrasts'), 'contrast_tmp', 'contrast_org');
disp('done')

%END