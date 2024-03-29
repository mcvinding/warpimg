%% Plot DICS source results
% 
% Vinding, M. C., & Oostenveld, R. (2022). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality. NeuroImage, 119165. https://doi.org/10.1016/j.neuroimage.2022.119165
%
% Plot results of DICS source reconstructions of induced response (Figure 5).

close all
addpath('~/fieldtrip/fieldtrip')
ft_defaults

%% Paths
data_path = '~/mri_warpimg/data/0177/170424';
out_path  = '~/mri_warpimg/figures';

%% Load data
fprintf('Loading... ')
load(fullfile(data_path, 'dics_org'));
load(fullfile(data_path, 'dics_tmp'));
load(fullfile(data_path, 'dics_contrasts'));

% Load MRI
load(fullfile(data_path, 'mri_warptmp.mat'));
load(fullfile(data_path, 'mri_org_resliced.mat'));
mri_org_resliced.anatomy(mri_org_resliced.anatomy>5000) = 5000;
disp('done')

%% Plot settings
pos = [41 4 116];           % Force same view on all plots
lim = [-0.125 0.125];       % Color limits

%% Plot original result
cfg = [];
cfg.downsample  = 1;
cfg.parameter   = 'pow';
beam_int_org = ft_sourceinterpolate(cfg, contrast_org, mri_org_resliced);

cfg = [];
cfg.method          = 'ortho';
cfg.funparameter    = 'pow';
cfg.location        = pos;
cfg.funcolorlim     = lim;
cfg.crosshair       = 'no';
cfg.axis            = 'off';
cfg.colorbartext    = '';

ft_sourceplot(cfg, beam_int_org);

print(fullfile(out_path, 'dics_org.png'), '-dpng')

%% Plot template result
cfg = [];
cfg.downsample  = 1;
cfg.parameter   = 'pow';
beam_int_tmp = ft_sourceinterpolate(cfg, contrast_tmp, mri_warptmp);

cfg = [];
cfg.method          = 'ortho';
cfg.funparameter    = 'pow';
cfg.location        = pos;
cfg.funcolorlim     = lim;
cfg.crosshair       = 'no';
cfg.axis            = 'off';

ft_sourceplot(cfg, beam_int_tmp);

print(fullfile(out_path, 'dics_tmp.png'), '-dpng')

%% Plot difference
contrast_tmp_norm = contrast_tmp;
contrast_tmp_norm.pos = contrast_org.pos;

cfg = [];
cfg.parameter   = 'pow';
cfg.operation   = 'subtract';
contrast_diff = ft_math(cfg, contrast_tmp_norm, contrast_org);

% Interpolate
cfg = [];
cfg.downsample  = 1;
cfg.parameter   = 'pow';
diff_int = ft_sourceinterpolate(cfg, contrast_diff, mri_org_resliced);

% Plot
cfg = [];
cfg.method          = 'ortho';
cfg.funparameter    = 'pow';
cfg.location        = pos; %diff_int.pos(idx,:);
cfg.funcolorlim     = lim/2;
cfg.crosshair       = 'no';
cfg.axis            = 'off';

ft_sourceplot(cfg, diff_int);

print(fullfile(out_path, 'dics_dif.png'), '-dpng')

%% Source power histograms
figure;
set(gcf,'Position',[0 0 1000 400])

subplot(1,3,1); hold on
histogram(log(dics_desy_org.avg.pow))
histogram(log(dics_desy_tmp.avg.pow))
legend('Original MRI','Warped template')
xlabel('Log-power')
ylim([0 1200]);
title('Desync. power')
set(gca,'linewidth', 1.5)

subplot(1,3,2); hold on
histogram(log(dics_base_org.avg.pow))
histogram(log(dics_base_tmp.avg.pow))
legend('Original MRI','Warped template')
xlabel('Log-power')
ylim([0 1200]);
title('Baseline power')
set(gca,'linewidth', 1.5)

subplot(2,3,3);
scatter(log(dics_desy_org.avg.pow), log(dics_desy_tmp.avg.pow), '.k')
xlim([-6 6]); ylim([-6 6])
% xlabel('Log-power (orig. MRI)')
ylabel('Log-power (warp temp.)')
title('Desync. power')
set(gca,'linewidth', 1.5)

subplot(2,3,6);
scatter(log(dics_base_org.avg.pow), log(dics_base_tmp.avg.pow), '.k')
xlim([-6 6]); ylim([-6 6])
xlabel('Log-power (orig. MRI)')
ylabel('Log-power (warp temp.)')
title('Baseline power')
set(gca,'linewidth', 1.5)

print(fullfile(out_path, 'dics_summary.png'), '-dpng')

%END