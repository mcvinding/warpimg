%% Plot dipole model results
% 
% <<REF>>
%
% Plot results of dipole fits (Figure N).

addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177';
out_path = '/home/mikkel/mri_warpimg/figures';
cd(out_path)

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

%% Plot single dip location on original MRI
% Grads
figure; hold on
pos = dip_grad_early_tmp.dip.pos;
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
ft_plot_dipole(dip_grad_early_org.dip.pos, mean(dip_grad_early_org.dip.mom,2), 'diameter', 10, 'unit', 'mm', 'color','c');
ft_plot_dipole(dip_grad_early_tmp.dip.pos, mean(dip_grad_early_tmp.dip.mom,2), 'diameter', 10, 'unit', 'mm', 'color','r');
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip1_slice_grad_tmp.png'), '-dpng')

% Mags
figure; hold on
pos = dip_mag_early_tmp.dip.pos;
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_org_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
ft_plot_dipole(dip_mag_early_org.dip.pos, mean(dip_mag_early_org.dip.mom,2), 'diameter', 10, 'unit', 'mm', 'color','c');
ft_plot_dipole(dip_mag_early_tmp.dip.pos, mean(dip_mag_early_tmp.dip.mom,2), 'diameter', 10, 'unit', 'mm', 'color','r');
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip1_slice_mags_tmp.png'), '-dpng')

close all

%% Plot single dip location on warped template
% Grads
figure; hold on
pos = dip_grad_early_tmp.dip.pos;
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
ft_plot_dipole(dip_grad_early_org.dip.pos, mean(dip_grad_early_org.dip.mom,2), 'diameter', 10, 'unit', 'mm', 'color','c');
ft_plot_dipole(dip_grad_early_tmp.dip.pos, mean(dip_grad_early_tmp.dip.mom,2), 'diameter', 10, 'unit', 'mm', 'color','r');
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip1_slice_grad.png'), '-dpng')

% Mags
figure; hold on
pos = dip_mag_early_tmp.dip.pos;
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
ft_plot_dipole(dip_mag_early_org.dip.pos, mean(dip_mag_early_org.dip.mom,2), 'diameter', 10, 'unit', 'mm', 'color','c');
ft_plot_dipole(dip_mag_early_tmp.dip.pos, mean(dip_mag_early_tmp.dip.mom,2), 'diameter', 10, 'unit', 'mm', 'color','r');
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip1_slice_mags.png'), '-dpng')

close all


%% Plot dual dip location on original MRI
% Grads
figure; hold on
pos = mean(dip_grad_late_tmp.dip.pos(1,:),1);
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
ft_plot_dipole(dip_grad_late_tmp.dip.pos(1,:), mean(dip_grad_late_tmp.dip.mom(1:3,:),2), 'diameter', 10, 'unit', 'mm', 'color','r'); hold on
ft_plot_dipole(dip_grad_late_tmp.dip.pos(2,:), mean(dip_grad_late_tmp.dip.mom(4:6,:),2), 'diameter', 10, 'unit', 'mm', 'color','r'); hold on
ft_plot_dipole(dip_grad_late_org.dip.pos(1,:), mean(dip_grad_late_org.dip.mom(1:3,:),2), 'diameter', 10, 'unit', 'mm', 'color','c'); hold on
ft_plot_dipole(dip_grad_late_org.dip.pos(2,:), mean(dip_grad_late_org.dip.mom(4:6,:),2), 'diameter', 10, 'unit', 'mm', 'color','c'); hold on
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip2_slice_grad.png'), '-dpng')

% Mags
figure; hold on
pos = mean(dip_mag_late_tmp.dip.pos(1,:),1);
ft_plot_slice(mri_org_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(1,:), mean(dip_mag_late_tmp.dip.mom(1:3,:),2), 'diameter', 10, 'unit', 'mm', 'color','r'); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(2,:), mean(dip_mag_late_tmp.dip.mom(4:6,:),2), 'diameter', 10, 'unit', 'mm', 'color','r'); hold on
ft_plot_dipole(dip_mag_late_org.dip.pos(1,:), mean(dip_mag_late_org.dip.mom(1:3,:),2), 'diameter', 10, 'unit', 'mm', 'color','c'); hold on
ft_plot_dipole(dip_mag_late_org.dip.pos(2,:), mean(dip_mag_late_org.dip.mom(4:6,:),2), 'diameter', 10, 'unit', 'mm', 'color','c'); hold on
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip2_slice_mags.png'), '-dpng')

close all

%% Plot dual dip location on warped template
% Grads
figure; hold on
pos = mean(dip_grad_late_tmp.dip.pos(1,:),1);
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
ft_plot_dipole(dip_grad_late_tmp.dip.pos(1,:), mean(dip_grad_late_tmp.dip.mom(1:3,:),2), 'diameter', 10, 'unit', 'mm', 'color','r'); hold on
ft_plot_dipole(dip_grad_late_tmp.dip.pos(2,:), mean(dip_grad_late_tmp.dip.mom(4:6,:),2), 'diameter', 10, 'unit', 'mm', 'color','r'); hold on
ft_plot_dipole(dip_grad_late_org.dip.pos(1,:), mean(dip_grad_late_org.dip.mom(1:3,:),2), 'diameter', 10, 'unit', 'mm', 'color','c'); hold on
ft_plot_dipole(dip_grad_late_org.dip.pos(2,:), mean(dip_grad_late_org.dip.mom(4:6,:),2), 'diameter', 10, 'unit', 'mm', 'color','c'); hold on
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip2_slice_grad_tmp.png'), '-dpng')

% Mags
figure; hold on
pos = mean(dip_mag_late_tmp.dip.pos(1,:),1);
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos, 'orientation', [0 1 0]); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(1,:), mean(dip_mag_late_tmp.dip.mom(1:3,:),2), 'diameter', 10, 'unit', 'mm', 'color','r'); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(2,:), mean(dip_mag_late_tmp.dip.mom(4:6,:),2), 'diameter', 10, 'unit', 'mm', 'color','r'); hold on
ft_plot_dipole(dip_mag_late_org.dip.pos(1,:), mean(dip_mag_late_org.dip.mom(1:3,:),2), 'diameter', 10, 'unit', 'mm', 'color','c'); hold on
ft_plot_dipole(dip_mag_late_org.dip.pos(2,:), mean(dip_mag_late_org.dip.mom(4:6,:),2), 'diameter', 10, 'unit', 'mm', 'color','c'); hold on
view([0 -1 0])

% Export
print(fullfile(out_path, 'dip2_slice_mags_tmp.png'), '-dpng')

close all

%% Full time series and residual variance
idxr = 1:2:100;

% Mags
figure; set(gcf,'Position',[0 0 1000 400]); hold on

subplot(3,2, [1,3]); hold on
set(gca,'linewidth', 1.5)
y1 = sqrt(sum(dip_mag_all_org.dip.mom).^2);
y2 = sqrt(sum(dip_mag_all_tmp.dip.mom).^2);
plot(dip_mag_all_org.time, y1, 'b', 'linewidth', 2)
plot(dip_mag_all_tmp.time, y2, 'r', 'linewidth', 2)
scatter(dip_mag_all_org.time(idxr), y1(idxr), 'bx')
scatter(dip_mag_all_tmp.time(idxr), y2(idxr), 'rx')

title('Single dipole: magnetometers');
legend('Original','Warped template')
xlim([0 0.5])

subplot(3,2,5); hold on
set(gca,'linewidth', 1.5)
plot(dip_mag_all_org.time, dip_mag_all_org.dip.rv, 'b', 'linewidth', 2)
plot(dip_mag_all_tmp.time, dip_mag_all_tmp.dip.rv, 'r', 'linewidth', 2)
scatter(dip_mag_all_org.time(idxr), dip_mag_all_org.dip.rv(idxr), 'bx')
scatter(dip_mag_all_org.time(idxr), dip_mag_all_tmp.dip.rv(idxr), 'rx')
xlim([0 0.5])
title('Residual variance');

% Grads
subplot(3,2, [2,4]); hold on
set(gca,'linewidth', 1.5)
y1 = sqrt(sum(dip_grad_all_org.dip.mom).^2);
y2 = sqrt(sum(dip_grad_all_tmp.dip.mom).^2);
plot(dip_mag_all_org.time, y1, 'b', 'linewidth', 2)
plot(dip_mag_all_tmp.time, y2, 'r', 'linewidth', 2)
scatter(dip_grad_all_org.time(idxr), y1(idxr), 'bx')
scatter(dip_grad_all_tmp.time(idxr), y2(idxr), 'rx')
title('Single dipole: gradiomenters')
legend('Original','Warped template')
xlim([0 0.5])

subplot(3,2,6); hold on
set(gca,'linewidth', 1.5)
plot(dip_grad_all_org.time, dip_grad_all_org.dip.rv, 'b', 'linewidth', 2)
plot(dip_grad_all_tmp.time, dip_grad_all_tmp.dip.rv, 'r', 'linewidth', 2)
scatter(dip_grad_all_org.time(idxr), dip_grad_all_org.dip.rv(idxr), 'bx')
scatter(dip_grad_all_tmp.time(idxr), dip_grad_all_tmp.dip.rv(idxr), 'rx')
xlim([0 0.5])
title('Residual variance');

% Export
print(fullfile(out_path, 'dip_tc_all.png'), '-dpng')

%END