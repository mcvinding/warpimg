% Reliability analysis of source reconstructed data using Krippendorff's
% alpha.
addpath('/home/mikkel/reliability_analysis/') %https://github.com/mcvinding/reliability_analysis

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177';

%% A) Dipole time-series
% Load data
load(fullfile(data_path, 'dip_mag_all.mat'))
load(fullfile(data_path, 'dip_grad_all.mat'))

% Comparison
dat = [sqrt(sum(dip_mag_all_org.dip.mom).^2); sqrt(sum(dip_mag_all_tmp.dip.mom).^2)];
a_mag_all = reliability_analysis(dat, 'n2fast');

dat = [sqrt(sum(dip_grad_all_org.dip.mom).^2); sqrt(sum(dip_grad_all_tmp.dip.mom).^2)];
a_grad_all = reliability_analysis(dat, 'n2fast');

%% B) DICS source maps
fprintf('Loading data... ')
load(fullfile(data_path, 'dics_contrasts'))
disp('done')

dat = [contrast_org.pow(contrast_org.inside)'; contrast_tmp.pow(contrast_tmp.inside)'];
   
a_dics = reliability_analysis(dat, 'n2fast');

%% C) Virtual electrodes
fprintf('Loading data... ')
load(fullfile(data_path, 'vrtavg_org.mat'))
load(fullfile(data_path, 'vrtavg_tmp.mat'))
disp('done')

% For each "channel"
a_vrtchans = nan(1, length(vrtavg_org.label));
for ii = 1:length(vrtavg_org.label)
    dat = [ vrtavg_org.avg(ii,:); vrtavg_tmp.avg(ii,:)];
    a_vrtchans(ii) = reliability_analysis(dat, 'n2fast');
end

% All
dat = [ vrtavg_org.avg(:)'; vrtavg_tmp.avg(:)'];
a_vrtchan = reliability_analysis(dat, 'n2fast');


%% D) MNE
fprintf('Loading data... ')
load(fullfile(data_path, 'mnesource_org.mat'));
load(fullfile(data_path, 'mnesource_tmp.mat'));
disp('DONE')


dat = [mnesource_org.avg.pow(:)'; mnesource_tmp.avg.pow(:)'];
a_mne = reliability_analysis(dat, 'n2fast');

dat2 = log(dat);

a_mne2 = reliability_analysis(dat2, 'alphaprime');
a_mne3 = reliability_analysis(dat2, 'n2fast');

%% Save results
fprintf('Save results... ')
save(fullfile(data_path, 'alphas.mat'), 'a_*');
disp('DONE')

%END