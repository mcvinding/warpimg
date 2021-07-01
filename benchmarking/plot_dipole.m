%% Comparison of dipole models
% 
% <<REF>>
%
% Plot results of dipole fits.

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
load(fullfile(data_path, 'evoked.mat'));
disp('done')

fprintf('loading MRIs... ')
load(fullfile(data_path, 'mri_tmp_resliced'));
load(fullfile(data_path, 'mri_org_resliced'));
load(fullfile(data_path, 'headmodel_tmp.mat'));
load(fullfile(data_path, 'headmodel_org.mat'));
disp('done')

% Rescale MRI intensity for plotting
mri_org_resliced.anatomy(mri_org_resliced.anatomy>5000) = 5000;

%% Convert dip units for plotting
dip_mag_early_org.dip = ft_convert_units(dip_mag_early_org.dip, 'mm');
dip_mag_early_tmp.dip = ft_convert_units(dip_mag_early_tmp.dip, 'mm');

dip_mag_late_org.dip = ft_convert_units(dip_mag_late_org.dip, 'mm');
dip_mag_late_tmp.dip = ft_convert_units(dip_mag_late_tmp.dip, 'mm');

dip_grad_early_org.dip = ft_convert_units(dip_grad_early_org.dip, 'mm');
dip_grad_early_tmp.dip = ft_convert_units(dip_grad_early_tmp.dip, 'mm');

dip_grad_late_org.dip = ft_convert_units(dip_grad_late_org.dip, 'mm');
dip_grad_late_tmp.dip = ft_convert_units(dip_grad_late_tmp.dip, 'mm');

dip_grad_all_org.dip = ft_convert_units(dip_grad_all_org.dip, 'mm');
dip_grad_all_tmp.dip = ft_convert_units(dip_grad_all_tmp.dip, 'mm');

%% Inspect
% figure; hold on
% ft_determine_coordsys(mri_org_resliced, 'interactive', 'no'); hold on;
% ft_plot_sens(evoked.grad, 'color', 'r');
% ft_plot_headmodel(headmodel_org, 'facealpha', 0.5, 'facecolor', 'r')
% ft_plot_dipole(dip_grad_early_org.dip.pos, mean(dip_grad_early_org.dip.mom,2), 'size',2, 'unit', 'mm'); hold on

%% Compare dip: mags early component
% Distance error
norm(dip_mag_early_org.dip.pos-dip_mag_early_tmp.dip.pos)

%% Compare dip: mags late component
norm(dip_mag_late_org.dip.pos(1,:)-dip_mag_late_tmp.dip.pos(1,:))
norm(dip_mag_late_org.dip.pos(2,:)-dip_mag_late_tmp.dip.pos(2,:))

%% Compare dip: grads early component
norm(dip_grad_early_org.dip.pos-dip_grad_early_tmp.dip.pos)

%% Compare dip: grads late component
norm(dip_grad_late_org.dip.pos(1,:)-dip_grad_late_tmp.dip.pos(1,:))
norm(dip_grad_late_org.dip.pos(2,:)-dip_grad_late_tmp.dip.pos(2,:))

%% Plot single dip location
% Grads
figure; hold on
pos = dip_grad_early_tmp.dip.pos;
% ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [1 0 0]); hold on
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
% ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [0 0 1]);
ft_plot_dipole(dip_grad_early_org.dip.pos, mean(dip_grad_early_org.dip.mom,2), 'size', 15, 'unit', 'mm', 'color','b');
ft_plot_dipole(dip_grad_early_tmp.dip.pos, mean(dip_grad_early_tmp.dip.mom,2), 'size', 15, 'unit', 'mm');
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip1_slice_grad.png'), '-dpng')

% Mags
figure; hold on
pos = dip_mag_early_tmp.dip.pos;
% ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [1 0 0]); hold on
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
% ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [0 0 1]);
ft_plot_dipole(dip_mag_early_org.dip.pos, mean(dip_mag_early_org.dip.mom,2), 'size', 15, 'unit', 'mm', 'color','b');
ft_plot_dipole(dip_mag_early_tmp.dip.pos, mean(dip_mag_early_tmp.dip.mom,2), 'size', 15, 'unit', 'mm');
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip1_slice_mags.png'), '-dpng')

close all

%% Plot dual dip location
% Grads
figure; hold on
pos = mean(dip_grad_late_tmp.dip.pos(1,:),1);
% ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [1 0 0]); hold on
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 1 0]); hold on
% ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 0 1]); hold on
ft_plot_dipole(dip_grad_late_tmp.dip.pos(1,:), mean(dip_grad_late_tmp.dip.mom(1:3,:),2), 'size',2, 'unit', 'mm'); hold on
ft_plot_dipole(dip_grad_late_tmp.dip.pos(2,:), mean(dip_grad_late_tmp.dip.mom(4:6,:),2), 'size',2, 'unit', 'mm'); hold on
ft_plot_dipole(dip_grad_late_org.dip.pos(1,:), mean(dip_grad_late_org.dip.mom(1:3,:),2), 'size',2, 'unit', 'mm','color','b'); hold on
ft_plot_dipole(dip_grad_late_org.dip.pos(2,:), mean(dip_grad_late_org.dip.mom(4:6,:),2), 'size',2, 'unit', 'mm','color','b'); hold on
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip2_slice_grad.png'), '-dpng')

% Mags
figure; hold on
pos = mean(dip_mag_late_tmp.dip.pos(1,:),1);
% ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [1 0 0]); hold on
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 1 0]); hold on
% ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 0 1]); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(1,:), mean(dip_mag_late_tmp.dip.mom(1:3,:),2), 'size',2, 'unit', 'mm'); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(2,:), mean(dip_mag_late_tmp.dip.mom(4:6,:),2), 'size',2, 'unit', 'mm'); hold on
ft_plot_dipole(dip_mag_late_org.dip.pos(1,:), mean(dip_mag_late_org.dip.mom(1:3,:),2), 'size',2, 'unit', 'mm','color','b'); hold on
ft_plot_dipole(dip_mag_late_org.dip.pos(2,:), mean(dip_mag_late_org.dip.mom(4:6,:),2), 'size',2, 'unit', 'mm','color','b'); hold on
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip2_slice_mags.png'), '-dpng')

close all

%% Full time series and residual variance
% Mags
figure; set(gcf,'Position',[0 0 1000 400]); hold on

subplot(3,2, [1,3]); hold on
plot(dip_mag_all_org.time, sqrt(sum(dip_mag_all_org.dip.mom).^2), 'b')
plot(dip_mag_all_tmp.time, sqrt(sum(dip_mag_all_tmp.dip.mom).^2), 'r')
title('Single dipole model: magnetometers');
legend('Original','Warped template')
xlim([0 0.5])

subplot(3,2,5); hold on
plot(dip_mag_all_org.time, dip_mag_all_org.dip.rv, 'b')
plot(dip_mag_all_tmp.time, dip_mag_all_tmp.dip.rv, 'r')
xlim([0 0.5])
title('Residual variance');

% Grads
subplot(3,2, [2,4]); hold on
plot(dip_grad_all_org.time, sqrt(sum(dip_grad_all_org.dip.mom).^2), 'b')
plot(dip_grad_all_tmp.time, sqrt(sum(dip_grad_all_tmp.dip.mom).^2), 'r')
title('Single dipole model: gradiomenters')
legend('Original','Warped template')
xlim([0 0.5])

subplot(3,2,6); hold on
plot(dip_grad_all_org.time, dip_grad_all_org.dip.rv, 'b')
plot(dip_grad_all_tmp.time, dip_grad_all_tmp.dip.rv, 'r')
xlim([0 0.5])
title('Residual variance');

% Export
print(fullfile(out_path, 'dip_tc_all.png'), '-dpng')

%END