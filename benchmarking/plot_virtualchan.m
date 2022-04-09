%% Plot virtual channel source results
% 
% Vinding, M. C., & Oostenveld, R. (2022). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality. NeuroImage, 119165. https://doi.org/10.1016/j.neuroimage.2022.119165
%
% Plot results of LCMV beamformer virtual channels (Figure 6).

close all
addpath('~/fieldtrip/fieldtrip')
ft_defaults

%% Paths
data_path = '~/mri_warpimg/data/0177/170424';
out_path  = '~/mri_warpimg/figures';

%% Load data
fprintf('Loading... ')
load(fullfile(data_path, 'vrtavg_org.mat'))
load(fullfile(data_path, 'vrtavg_tmp.mat'))
disp('done')

%% Plot
% idxr = 1:4:200;
xx = [min(vrtavg_org.time),max(vrtavg_org.time)];
yy = [-15e-11 15e-11];

figure; set(gcf,'Position',[0 0 1000 1000]); hold on

subplot(5,2,1); hold on
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(1,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(1,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(1,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(1,idxr), 'rx')
title(vrtavg_org.label(1), 'Interpreter','none'); 
xlim(xx); ylim(yy)

subplot(5,2,2); hold on 
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(2,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(2,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(2,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(2,idxr), 'rx')
title(vrtavg_org.label(2), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,3); hold on
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(5,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(5,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(5,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(5,idxr), 'rx')
title(vrtavg_org.label(5), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,4); hold on
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(6,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(6,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(6,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(6,idxr), 'rx')
title(vrtavg_org.label(6), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,5); hold on
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(3,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(3,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(3,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(3,idxr), 'rx')
title(vrtavg_org.label(3), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,6); hold on
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(4,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(4,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(4,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(4,idxr), 'rx')
title(vrtavg_org.label(4), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,7); hold on
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(7,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(7,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(7,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(7,idxr), 'rx')
title(vrtavg_org.label(7), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,8); hold on
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(8,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(8,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(8,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(8,idxr), 'rx')
title(vrtavg_org.label(8), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,9); hold on
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(9,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(9,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(9,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(9,idxr), 'rx')
title(vrtavg_org.label(9), 'Interpreter','none');
xlim(xx); ylim(yy)

subplot(5,2,10); hold on
set(gca,'linewidth', 1.5)
plot(vrtavg_org.time, vrtavg_org.avg(10,:), 'b', 'linewidth', 2)
plot(vrtavg_tmp.time, vrtavg_tmp.avg(10,:), 'r:', 'linewidth', 2)
% scatter(vrtavg_org.time(idxr), vrtavg_org.avg(10,idxr), 'bx')
% scatter(vrtavg_tmp.time(idxr), vrtavg_tmp.avg(10,idxr), 'rx')
title(vrtavg_org.label(10), 'Interpreter','none');
xlim(xx); ylim(yy)

print(fullfile(out_path, 'vrtchanplot.png'), '-dpng')

%END