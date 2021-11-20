%% Plot headmodels 
%
% Vinding, M. C., & Oostenveld, R. (2021). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality [Preprint]. bioRxiv.org. https://doi.org/10.1101/2021.11.
%
% Plot the headmodels (volume conductor models) created from the original
% MRI and the warped template superimposed to compare geometry (Figure 3).

addpath('~/fieldtrip/fieldtrip/')
ft_defaults
addpath('~/reliability_analysis/') % https://github.com/mcvinding/reliability_analysis

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177/170424';
out_path  = '/home/mikkel/mri_warpimg/figures';

%% Load headmodels
load(fullfile(data_path, 'headmodel_tmp.mat'))
load(fullfile(data_path, 'headmodel_org.mat'))

%% Plot headmodels
figure; set(gcf,'Position',[0 0 1200 400]); hold on

subplot(1,3,1); hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.4, 'facecolor', 'b')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
view([0 1 0]); title('Coronal')

subplot(1,3,2); hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.4, 'facecolor', 'b')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
view([1 0 0]); title('Sagittal')

subplot(1,3,3); hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.4, 'facecolor', 'b')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
view([0 0 1]); title('Axial')

print(fullfile(out_path, 'headmodels.png'), '-dpng')

%END
