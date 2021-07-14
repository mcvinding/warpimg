%% Plot ERF
% 
% <<REF>>
%
% the ERF and topographies (Figure 1).

addpath('~/fieldtrip/fieldtrip')
ft_defaults

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177';
out_path = '/home/mikkel/mri_warpimg/figures';

%% Load data
fprintf('Loading data...')
load(fullfile(data_path, 'evoked.mat'));
disp('done')

%% ERF multiplot
figure; set(gcf,'Position',[0 0 700 600])
cfg = [];
cfg.layout          = 'neuromag306mag';
cfg.showlabels      = 'no';
cfg.showcomment     = 'no';
cfg.showscale       = 'no';
cfg.linecolor       = 'k';
ft_multiplotER(cfg, evoked);

% Export
print(fullfile(out_path, 'erf_multiplot.png'), '-dpng')

%% ERF singleplot
figure; set(gcf,'Position',[0 0 600 200])
cfg = [];
cfg.channel         = 'MEG0221';
cfg.title           = '';
cfg.linecolor       = 'k';
cfg.linewidth       = 2;
ft_singleplotER(cfg, evoked)
set(gca,'linewidth', 1.5)

% Export
print(fullfile(out_path, 'erf_singleplot.png'), '-dpng')

%% Example topographies
figure; set(gcf,'Position',[0 0 500 500])
cfg = [];
cfg.title           = '';
cfg.xlim            = [0.05 0.06];
cfg.layout          = 'neuromag306mag';
cfg.comment         = 'no';
cfg.marker          = 'off';
ft_topoplotER(cfg, evoked)

% Export
print(fullfile(out_path, 'erf_topoSI.png'), '-dpng')

figure; set(gcf,'Position',[0 0 500 500])
cfg = [];
cfg.title           = '';
cfg.xlim            = [0.13 0.18];
cfg.layout          = 'neuromag306mag';
cfg.comment         = 'no';
cfg.marker          = 'off';
ft_topoplotER(cfg, evoked)

% Export
print(fullfile(out_path, 'erf_topoSII.png'), '-dpng')

figure; set(gcf,'Position',[0 0 500 500])
cfg = [];
cfg.title           = '';
cfg.xlim            = [0.27 0.38];
cfg.layout          = 'neuromag306mag';
cfg.comment         = 'no';
cfg.marker          = 'off';
ft_topoplotER(cfg, evoked)

% Export
print(fullfile(out_path, 'erf_topoLate.png'), '-dpng')

close all