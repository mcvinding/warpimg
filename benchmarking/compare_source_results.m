%% Reliability analysis of source reconstructed data using Krippendorff's
% alpha.
% 
% <<REF>>
%
% Compare the results of MEG source reconstructions from 1) dipole fits, 2)
% DICS beamformer, 3) LCMV beamformer virtual channels, and D) minimum-norm
% estimates. Compare similarity using Krippendorff Alpha
% (https://github.com/mcvinding/reliability_analysis), as reported in the
% article. Additional reliability analysis using interclass correlation
% coefficent (ICC).

% ICC script: Arash Salarian (2021). Intraclass Correlation Coefficient (ICC) (https://www.mathworks.com/matlabcentral/fileexchange/22099-intraclass-correlation-coefficient-icc), MATLAB Central File Exchange. Retrieved June 8, 2021.

addpath('/home/mikkel/reliability_analysis/') % https://github.com/mcvinding/reliability_analysis

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177';

%% A) Dipole time-series
% Load data
load(fullfile(data_path, 'dip_mag_all.mat'))
load(fullfile(data_path, 'dip_grad_all.mat'))

% Comparison: mags
dat = [sqrt(sum(dip_mag_all_org.dip.mom).^2); sqrt(sum(dip_mag_all_tmp.dip.mom).^2)];
a_mag_all = reliability_analysis(dat, 'n2fast');

[icca_mag_all, lba, uba] = ICC(dat', 'A-1');
[iccc_mag_all, lbc, ubc] = ICC(dat', 'C-1');

% Comparison: grads
dat = [sqrt(sum(dip_grad_all_org.dip.mom).^2); sqrt(sum(dip_grad_all_tmp.dip.mom).^2)];
a_grad_all = reliability_analysis(dat, 'n2fast');

[icca_grad_all, lba, uba] = ICC(dat', 'A-1');
[iccc_grad_all, lbc, ubc] = ICC(dat', 'C-1');

%% B) DICS source maps
fprintf('Loading data... ')
load(fullfile(data_path, 'dics_contrasts'))
disp('done')

dat = [contrast_org.pow(contrast_org.inside)'; contrast_tmp.pow(contrast_tmp.inside)'];
   
a_dics = reliability_analysis(dat, 'n2fast');

[icca_dics, lba, uba] = ICC(dat', 'A-1');
[iccc_dics, lbc, ubc] = ICC(dat', 'C-1');

%% C) Virtual electrodes
fprintf('Loading data... ')
load(fullfile(data_path, 'vrtavg_org.mat'))
load(fullfile(data_path, 'vrtavg_tmp.mat'))
disp('done')

% For each "channel"
a_vrtchans = nan(1, length(vrtavg_org.label));
icca_vrtchans = nan(1, length(vrtavg_org.label));
iccc_vrtchans = nan(1, length(vrtavg_org.label));
lba = nan(1, length(vrtavg_org.label));
lbc = nan(1, length(vrtavg_org.label));
uba = nan(1, length(vrtavg_org.label));
ubc = nan(1, length(vrtavg_org.label));

for ii = 1:length(vrtavg_org.label)
    dat = [ vrtavg_org.avg(ii,:); vrtavg_tmp.avg(ii,:)];
%     a_vrtchans(ii) = reliability_analysis(dat, 'n2fast');
    [icca_vrtchans(ii), lba(ii), uba(ii)] = ICC(dat', 'A-1');
    [iccc_vrtchans(ii), lbc(ii), ubc(ii)] = ICC(dat', 'C-1');
end

% All
dat = [ vrtavg_org.avg(:)'; vrtavg_tmp.avg(:)'];
a_vrtchan = reliability_analysis(dat, 'n2fast');
[icca_vrtchan, lba, uba] = ICC(dat', 'A-1');
[iccc_vrtchan, lbc, ubc] = ICC(dat', 'C-1');

%% D) MNE
fprintf('Loading data... ')
load(fullfile(data_path, 'mnesource_org.mat'));
load(fullfile(data_path, 'mnesource_tmp.mat'));
disp('DONE')

dat = [mnesource_org.avg.pow(:)'; mnesource_tmp.avg.pow(:)'];
a_mne = reliability_analysis(dat, 'n2fast');
a_mnex = reliability_analysis(dat, 'alphaprime');

[icca_mne, lba, uba] = ICC(dat', 'A-1');
[iccc_mne, lbc, ubc] = ICC(dat', 'C-1');

% Try log transform
dat2 = log(dat);
a_mne2 = reliability_analysis(dat2, 'alphaprime');
a_mne3 = reliability_analysis(dat2, 'n2fast');


%% Save results
fprintf('Save results... ')
save(fullfile(data_path, 'alphas.mat'), 'a_*');
disp('DONE')

%END