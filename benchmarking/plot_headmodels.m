%% Plot headmodels 
%
% <ref>
%
% Plot the headmodels (volume conductor models) created from the original
% MRI and the warped template superimposed to compare geometry (Figure 3).

addpath('~/fieldtrip/fieldtrip/')
ft_defaults
addpath('~/reliability_analysis/') % https://github.com/mcvinding/reliability_analysis

%% Paths
subjs = {'0177'};

data_path = '/home/mikkel/mri_warpimg/data/0177';
out_path = '/home/mikkel/mri_warpimg/figures';
ft_path   = '~/fieldtrip/fieldtrip/';

%% Load headmodels
load(fullfile(data_path, 'headmodel_tmp.mat'))
load(fullfile(data_path, 'headmodel_org.mat'))

%% Plot headmodels
figure; set(gcf,'Position',[0 0 1200 400]); hold on

subplot(1,3,1); hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.2, 'facecolor', 'c')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
view([0 1 0]); title('Coronal')

subplot(1,3,2); hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.2, 'facecolor', 'c')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
view([1 0 0]); title('Sagittal')

subplot(1,3,3); hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.2, 'facecolor', 'c')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
view([0 0 1]); title('Axial')

print(fullfile(out_path, 'headmodels.png'), '-dpng')

%END