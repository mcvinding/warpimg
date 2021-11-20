%% Prepare MEG data for source analysis. 
%
% Vinding, M. C., & Oostenveld, R. (2021). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality [Preprint]. bioRxiv.org. https://doi.org/10.1101/2021.11.
%
% Read preprocessed tutorial data and get epochs and evoked responses. Save
% the data for the epochs, the epochs cut to time of interest, and the
% evoked (averged) responses that are used in the MEG source analysis.

addpath('~/fieldtrip/fieldtrip')
ft_defaults

%% Folders
data_path = '/home/mikkel/mri_warpimg/data/0177/170424';

%% Load data
fprintf('Loading data... ')
load(fullfile(data_path,'cleaned_downsampled_data.mat'))
disp('done')

%% Select data (index finger stim)
cfg  = [];
cfg.channel = 'meg';
cfg.trials  = cleaned_downsampled_data.trialinfo==8;
data = ft_selectdata(cfg, cleaned_downsampled_data);

% Remove elec field and change unit
data = rmfield(data, 'elec');

%% Fix sensor info
data.grad = ft_read_sens('/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424/tactile_stim_raw_tsss_mc.fif', 'senstype', 'meg', 'coilaccuracy', 1);

%% Prepare epochs and evoked
cfg = [];
cfg.latency             = [-0.2 0.8];
data_slct = ft_selectdata(cfg, data);

% Ensure baseline
cfg = [];
cfg.demean              = 'yes';
cfg.baselinewindow      = [-inf 0];
epo = ft_preprocessing(cfg, data_slct);

% Average
cfg = [];
cfg.covariance          = 'yes';
cfg.covariancewindow    = 'prestim';
evoked = ft_timelockanalysis(cfg, epo);

%% Plot topographies (for inspection)
% cfg = [];
% cfg.layout = 'neuromag306mag.lay';
% ft_multiplotER(cfg, evoked);

% cfg = [];
% cfg.viewmode = 'butterfly';
% cfg.channels = 'grad'
% figure; ft_databrowser(cfg, data)

%% Save
fprintf('Saving...')
save(fullfile(data_path, 'data.mat'), 'data');
save(fullfile(data_path, 'epo.mat'), 'epo');
save(fullfile(data_path, 'evoked.mat'), 'evoked');
disp('done')

%% TFR (for inspection)
% Wavelet
cfg = [];
cfg.output          = 'pow';        
cfg.channel         = 'MEG';
cfg.method          = 'wavelet';
cfg.foi             = 5:1:30;
cfg.toi             = -0.2:0.01:0.8;
cfg.width           = 7;
cfg.pad             = 'nextpow2';

tfr = ft_freqanalysis(cfg, data);

cfg = [];
cfg.parameter       = 'powspctrm';
cfg.layout          = 'neuromag306mag';
cfg.showlabels      = 'yes';
cfg.baselinetype    = 'relative';  % Type of baseline, see help ft_multiplotTFR
cfg.baseline        = [-inf 0];    % Time of baseline

figure; ft_multiplotTFR(cfg, tfr);

%END
