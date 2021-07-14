%% Plot MNE source results
% 
% <<REF>>
%
% Plot results of MNE source reconstructions (Figure X).

close all
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Paths and filenames
data_path = '/home/mikkel/mri_warpimg/data/0177';
out_path = '/home/mikkel/mri_warpimg/figures';
cd(out_folder)

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
    cfg.funcolormap     = 'OrRd';    % Change for better color options
    cfg.latency         = times(tt);     % The time-point to plot (s)
    cfg.colorbar        = 'no';
    cfg.funcolorlim     = [lw, up];
    
    ft_sourceplot(cfg, mnesource_org); 
    set(gcf,'Position',[0 0 500 500]); hold on
%     title(['Original MRI (',num2str(times(tt)*1000),' ms)'], 'fontsize', 20);
    view([0 0 1])
    
    fname = ['mne_org',num2str(times(tt)*1000),'.png'];
    print(fname, '-dpng'); close
    
    ft_sourceplot(cfg, mnesource_tmp); 
    set(gcf,'Position',[0 0 500 500]); hold on
%     title(['Warped template MRI (',num2str(times(tt)*1000),' ms)'], 'fontsize', 20)
    view([0 0 1])

    fname = ['mne_tmp',num2str(times(tt)*1000),'.png'];
    print(fname, '-dpng'); close
    
    cfg.funcolormap     = 'RdBu';    % Change for better color options
    cfg.funcolorlim     = [min(mnediff.avg.pow(:))/2, max(mnediff.avg.pow(:)/2)];
    ft_sourceplot(cfg, mnediff); 
    set(gcf,'Position',[0 0 500 500]); hold on
%     title(['Difference (',num2str(times(tt)*1000),' ms)'], 'fontsize', 20)
    view([0 0 1])
    
    fname = ['mne_dif',num2str(times(tt)*1000),'.png'];
    print(fname, '-dpng'); close
end

%% Plot global mean power
tim = mnesource_org.time;
gmp_org = mean(mnesource_org.avg.pow);
gmp_tmp = mean(mnesource_tmp.avg.pow);

figure; set(gcf,'Position',[0 0 1000 400]); hold on
set(gca,'linewidth', 1.5)
plot(tim, gmp_org, 'b', 'linewidth', 2)
plot(tim, gmp_tmp, 'r', 'linewidth', 2)
xlim([min(tim), max(tim)])
xlabel('Time (s)'); ylabel('Global mean power')
yy = get(gca, 'ylim'); ylim(yy);
for ll = 1:length(times)
    line([times(ll), times(ll)], yy, 'color', 'k', 'linestyle', '--','linewidth', 1.5)
end

print(fullfile(out_folder, 'mne_globalpow.png'), '-dpng')

%END