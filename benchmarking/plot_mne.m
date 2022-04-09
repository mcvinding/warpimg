%% Plot MNE source results
% 
% Vinding, M. C., & Oostenveld, R. (2022). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality. NeuroImage, 119165. https://doi.org/10.1016/j.neuroimage.2022.119165
%
% Plot results of MNE source reconstructions (Figure 7).

close all
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Paths and filenames
data_path = '~/mri_warpimg/data/0177/170424';
out_path  = '~/mri_warpimg/figures';
cd(out_path)

%% (re)load
fprintf('Loading...');
load(fullfile(data_path, 'mnesource_org.mat'));
load(fullfile(data_path, 'mnesource_tmp.mat'));
disp('done')

%% Plot topographies
times = [0.000 0.072 0.162 0.237 0.307 0.480];

lw = min([mnesource_org.avg.pow(:); mnesource_tmp.avg.pow(:)]);
up = max([mnesource_org.avg.pow(:); mnesource_tmp.avg.pow(:)]);
up = 0.20*up;

mnediff = mnesource_org;
mnediff.avg.pow = mnesource_tmp.avg.pow-mnesource_org.avg.pow;

for tt = 1:length(times)
    cfg = [];
    cfg.method          = 'surface';
    cfg.funparameter    = 'pow';
    cfg.funcolormap     = 'OrRd';
    cfg.latency         = times(tt);     % The time-point to plot (s)
    cfg.colorbar        = 'no';
    cfg.funcolorlim     = [lw, up];
    cfg.facecolor       = 'brain';
    
%     ft_sourceplot(cfg, mnesource_org); 
%     set(gcf,'Position',[0 0 500 500]); hold on
% %     title(['Original MRI (',num2str(times(tt)*1000),' ms)'], 'fontsize', 20);
%     view([0 0 1])
%     
%     fname = ['mne_org',num2str(times(tt)*1000),'.png'];
%     print(fname, '-dpng'); close
%     
%     ft_sourceplot(cfg, mnesource_tmp); 
%     set(gcf,'Position',[0 0 500 500]); hold on
% %     title(['Warped template MRI (',num2str(times(tt)*1000),' ms)'], 'fontsize', 20)
%     view([0 0 1])
% 
%     fname = ['mne_tmp',num2str(times(tt)*1000),'.png'];
%     print(fname, '-dpng'); close
    
    cfg.funcolormap     = 'RdBu';
    cfg.funcolorlim     = [-max(mnediff.avg.pow(:)/2), max(mnediff.avg.pow(:)/2)];
    ft_sourceplot(cfg, mnediff); 
    set(gcf,'Position',[0 0 500 500]); hold on
%     title(['Difference (',num2str(times(tt)*1000),' ms)'], 'fontsize', 20)
    view([0 0 1])
    
    fname = ['mne_dif',num2str(times(tt)*1000),'.png'];
    print(fname, '-dpng'); close
end
disp('done');

%% Plot global mean power
tim = mnesource_org.time;
gmp_org = nanmean(mnesource_org.avg.pow);
gmp_tmp = nanmean(mnesource_tmp.avg.pow);

figure; set(gcf,'Position',[0 0 1000 400]); hold on
set(gca,'linewidth', 1.5)
plot(tim, gmp_org, 'b', 'linewidth', 2)
plot(tim, gmp_tmp, 'r', 'linewidth', 2)
xlim([min(tim), max(tim)])
xlabel('Time (s)'); ylabel('Global mean power')
yy = get(gca, 'ylim'); ylim(yy);
for ll = 1:length(times)
    line([times(ll), times(ll)], yy, 'color', 'k', 'linestyle', '--','linewidth', 1.0)
end

print(fullfile(out_path, 'mne_globalpow.png'), '-dpng')

%% Plot peak power
[~, pk_org] = max(max(mnesource_org.avg.pow,[],2));
[~, pk_tmp] = max(max(mnesource_tmp.avg.pow,[],2));

pk_coord_org = mnesource_org.pos(pk_org,:);
pk_coord_tmp = mnesource_tmp.pos(pk_tmp,:);

pk_ts_org = mnesource_org.avg.pow(pk_org, :);
pk_ts_tmp = mnesource_tmp.avg.pow(pk_tmp, :);

figure; set(gcf,'Position',[0 0 1000 400]); hold on
set(gca,'linewidth', 1.5)
plot(tim, pk_ts_org, 'b', 'linewidth', 2)
plot(tim, pk_ts_tmp, 'r', 'linewidth', 2)
xlim([min(tim), max(tim)])
xlabel('Time (s)'); ylabel('Peak vertex power')
yy = get(gca, 'ylim'); ylim(yy);
for ll = 1:length(times)
    line([times(ll), times(ll)], yy, 'color', 'k', 'linestyle', '--','linewidth', 1.0)
end

%END