%% Comparison of dip models
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Compute paths
data_path = '/home/mikkel/mri_warpimg/data/0177';
out_path = '/home/mikkel/mri_warpimg/figures';

%% Load data
fprintf('loading data... ')
load(fullfile(data_path, 'dip_mag_early.mat'))
load(fullfile(data_path, 'dip_mag_late.mat'))
load(fullfile(data_path, 'dip_grad_early.mat'))
load(fullfile(data_path, 'dip_grad_late.mat'))
load(fullfile(data_path, 'dip_mag_all.mat'));
load(fullfile(data_path, 'dip_grad_all.mat'));
disp('done')

fprintf('loading MRIs... ')
load(fullfile(data_path, 'mri_tmp_resliced'));
load(fullfile(data_path, 'mri_org_resliced'));
disp('done')

%% Rescale MRI intensity for plotting
mri_org_resliced.anatomy(mri_org_resliced.anatomy>7500) = 7500;

%% Inspect
figure; hold on
ft_determine_coordsys(mri_org_resliced, 'interactive', 'no'); hold on;
ft_plot_sens(evoked.grad);
ft_plot_headmodel(headmodel_org, 'facealpha', 0.5, 'facecolor', 'r')
ft_plot_dipole(dip_grad_early_org.dip.pos, mean(dip_grad_early_org.dip.mom,2), 'size',2, 'unit', 'mm'); hold on

%% Compare dip: mags early component
% Distance error
norm(dip_mag_early_org.dip.pos-dip_mag_early_tmp.dip.pos)

figure; hold on
plot(dip_mag_early_org.time, dip_mag_early_org.dip.rv)
plot(dip_mag_early_tmp.time, dip_mag_early_tmp.dip.rv)

%%
figure; hold on
pos = dip_mag_early_tmp.dip.pos;
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [1 0 0]); hold on
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [0 0 1]); hold on
ft_plot_dipole(dip_mag_early_org.dip.pos, mean(dip_mag_early_org.dip.mom,2), 'size',2, 'unit', 'mm','color','b'); hold on
ft_plot_dipole(dip_mag_early_tmp.dip.pos, mean(dip_mag_early_tmp.dip.mom,2), 'size',2, 'unit', 'mm'); hold on

%% Compare dip: mags late component
norm(dip_mag_late_org.dip.pos(1,:)-dip_mag_late_tmp.dip.pos(1,:))
norm(dip_mag_late_org.dip.pos(2,:)-dip_mag_late_tmp.dip.pos(2,:))

figure; hold on
plot(dip_mag_late_org.time,dip_mag_late_org.dip.rv)
plot(dip_mag_late_tmp.time,dip_mag_late_tmp.dip.rv)

figure; hold on
pos = mean(dip_mag_late_tmp.dip.pos(1,:),1);
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [1 0 0]); hold on
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 1 0]); hold on
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 0 1]); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(1,:), mean(dip_mag_late_tmp.dip.mom(1:3,:),2), 'size',2, 'unit', 'mm'); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(2,:), mean(dip_mag_late_tmp.dip.mom(4:6,:),2), 'size',2, 'unit', 'mm'); hold on
ft_plot_dipole(dip_mag_late_org.dip.pos(1,:), mean(dip_mag_late_org.dip.mom(1:3,:),2), 'size',2, 'unit', 'mm','color','b'); hold on
ft_plot_dipole(dip_mag_late_org.dip.pos(2,:), mean(dip_mag_late_org.dip.mom(4:6,:),2), 'size',2, 'unit', 'mm','color','b'); hold on

cfg = [];
cfg.location = dip_mag_late_org.dip.pos(1,:);
ft_sourceplot(cfg, mri_org_resliced);
ft_plot_dipole(dip_mag_late_org.dip.pos(1,:), mean(dip_mag_late_org.dip.mom(1:3,:),2), 'size',2, 'unit', 'mm','color','b'); hold on

cfg = [];
cfg.location = dip_mag_late_tmp.dip.pos(2,:);
ft_sourceplot(cfg, mri_tmp_resliced);
ft_plot_dipole(dip_mag_late_tmp.dip.pos(2,:), mean(dip_mag_late_tmp.dip.mom(4:6,:),2), 'size',2, 'unit', 'mm'); hold on

%% Compare dip: grads early component
norm(dip_grad_early_org.dip.pos-dip_grad_early_tmp.dip.pos)

%% Compare dip: grads late component
norm(dip_grad_late_org.dip.pos(1,:)-dip_grad_late_tmp.dip.pos(1,:))
norm(dip_grad_late_org.dip.pos(2,:)-dip_grad_late_tmp.dip.pos(2,:))

%% Full time
% Mags
figure; hold on
plot(dip_mag_all_org.time, dip_mag_all_org.dip.rv)
plot(dip_mag_all_tmp.time, dip_mag_all_tmp.dip.rv)
xlim([0 0.5])

figure; hold on
plot(dip_mag_all_org.time, sqrt(sum(dip_mag_all_org.dip.mom).^2))
plot(dip_mag_all_tmp.time, sqrt(sum(dip_mag_all_tmp.dip.mom).^2))
title('Single dipole model: magnetometers');
legend('Original','Warped template')
xlim([0 0.5])
print(fullfile(out_path, 'dip_tc_mags.png'), '-dpng')

% Grads
figure; hold on
plot(dip_grad_all_org.time, dip_grad_all_org.dip.rv)
plot(dip_grad_all_tmp.time, dip_grad_all_tmp.dip.rv)
xlim([0 0.5])

figure; hold on
plot(dip_grad_all_org.time, sqrt(sum(dip_grad_all_org.dip.mom).^2))
plot(dip_grad_all_tmp.time, sqrt(sum(dip_grad_all_tmp.dip.mom).^2))
title('Single dipole model: gradiomenters')
legend('Original','Warped template')
xlim([0 0.5])
print(fullfile(out_path, 'dip_tc_grad.png'), '-dpng')

%END