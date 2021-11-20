%% MNE source reconstruction
%
% Vinding, M. C., & Oostenveld, R. (2021). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality [Preprint]. bioRxiv.org. https://doi.org/10.1101/2021.11.18.469069
%
% Do MNE source reconstruction on evoked response. Plot results.
%
% Creation of source spaces was done with the ft_postfreesurferscript (in
% fieldtrip/bin) using the function in the HCPpipelines tools. For more
% information see the documentation for ft_postfreesurferscript. Examples
% on how to use the ft_postfreesurfer script is found in the file
% ./run_postfreesurfer.sh. 

close all; clear all
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177/170424';
fs_subject_dir = '/home/mikkel/mri_warpimg/fs_subjects_dir';

% Output filenames
mneOrg_outFname = fullfile(data_path, 'mnesource_org.mat');
mneTmp_outFname = fullfile(data_path, 'mnesource_tmp.mat');

%% Load data
fprintf('Loading... ')
load(fullfile(data_path, 'epo.mat'));
load(fullfile(data_path, 'mri_warptmp.mat'));
load(fullfile(data_path, 'mri_org_resliced.mat'));
load(fullfile(data_path, 'headmodel_tmp.mat'));
load(fullfile(data_path, 'headmodel_org.mat'));
disp('done')

%% Reading FreeSurfer Source Space
srcFname_orgL = fullfile(fs_subject_dir, '0177/workbench/0177.L.white.4k_fs_LR.surf.gii');
srcFname_orgR = fullfile(fs_subject_dir, '0177/workbench/0177.R.white.4k_fs_LR.surf.gii');
surfsrc_org = ft_read_headshape({srcFname_orgL, srcFname_orgR}, 'format', 'gifti');
surfsrc_org = ft_determine_units(surfsrc_org);
surfsrc_org = ft_convert_units(surfsrc_org, 'mm');

srcFname_tmpL = fullfile(fs_subject_dir,'0177warp/workbench/0177warp.L.white.4k_fs_LR.surf.gii');
srcFname_tmpR = fullfile(fs_subject_dir,'0177warp/workbench/0177warp.R.white.4k_fs_LR.surf.gii');
surfsrc_tmp = ft_read_headshape({srcFname_tmpL, srcFname_tmpR}, 'format', 'gifti');
surfsrc_tmp = ft_determine_units(surfsrc_tmp);
surfsrc_tmp = ft_convert_units(surfsrc_tmp, 'mm');

%% Plot for inspection
ft_determine_coordsys(mri_org_resliced, 'interactive', 'no'); hold on;
ft_plot_mesh(surfsrc_org, 'edgecolor','k')
ft_plot_headmodel(headmodel_org)

ft_determine_coordsys(mri_warptmp, 'interactive', 'no'); hold on;
ft_plot_mesh(surfsrc_tmp, 'edgecolor','k')
ft_plot_headmodel(headmodel_tmp)

%% Save surface source spaces
fprintf('Saving...')
save(fullfile(data_path, 'surfsrc_org'), 'surfsrc_org', '-v7.3');
save(fullfile(data_path, 'surfsrc_tmp'), 'surfsrc_tmp', '-v7.3');
disp('DONE')

%% Whiten data
cfg = [];
cfg.covariance          = 'yes';
cfg.covariancewindow    = 'prestim';
cfg.channel             = 'MEG';
data_cov = ft_timelockanalysis(cfg, epo);

[u,s,v] = svd(data_cov.cov);
d       = -diff(log10(diag(s)));
d       = d./std(d);
kappa   = find(d>5,1,'first');

cfg            = [];
cfg.channel    = 'meg';
cfg.kappa      = kappa;
dataw_meg      = ft_denoise_prewhiten(cfg, epo, data_cov);

cfg = [];
cfg.preproc.demean          = 'yes';
cfg.preproc.baselinewindow  = [-inf 0];
cfg.covariance              = 'yes';
cfg.covariancewindow        = 'prestim';
evoked = ft_timelockanalysis(cfg, dataw_meg);

% Plot
cfg = [];
cfg.layout = 'neuromag306all.lay';
ft_multiplotER(cfg, evoked);

%% Leadfields
cfg = [];
cfg.grad                = evoked.grad;      % sensor positions
cfg.channel             = 'meg';            % the used channels
cfg.senstype            = 'meg';

% Original
cfg.sourcemodel         = surfsrc_org;      % source points
cfg.headmodel           = headmodel_org;    % volume conduction model
lf_org = ft_prepare_leadfield(cfg, evoked);

% Template
cfg.sourcemodel         = surfsrc_tmp;      % source points
cfg.headmodel           = headmodel_tmp;    % volume conduction model
lf_tmp = ft_prepare_leadfield(cfg, evoked);

%% Do MNE
cfg                     = [];
cfg.method              = 'mne';
cfg.channel             = 'meggrad';
cfg.senstype            = 'meg';
cfg.mne.prewhiten       = 'no';
cfg.mne.lambda          = 2;
cfg.mne.scalesourcecov  = 'yes';

cfg.sourcemodel         = lf_org;
cfg.headmodel           = headmodel_org;
mnesource_org  = ft_sourceanalysis(cfg, evoked);

cfg.sourcemodel         = lf_tmp;
cfg.headmodel           = headmodel_tmp;
mnesource_tmp  = ft_sourceanalysis(cfg, evoked);

%% Inspect
cfg = [];
cfg.funparameter = 'pow';
ft_sourcemovie(cfg, mnesource_org);

cfg = [];
cfg.funparameter = 'pow';
ft_sourcemovie(cfg, mnesource_tmp);

%% Save source
fprintf('Saving...');
save(mneOrg_outFname, 'mnesource_org', '-v7.3');
save(mneTmp_outFname, 'mnesource_tmp', '-v7.3');
disp('done')

%END
