%% Comparison of MNE models
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Compute paths
% raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
% data_path = '/home/mikkel/mri_scripts/warpig/data/0177';
data_path = '/home/mikkel/mri_warpimg/data/0177';
fs_subject_dir = '/home/mikkel/mri_warpimg/fs_subjects_dir';

%% Load data
fprintf('Loading... ')
% load(fullfile(raw_folder, 'baseline_data.mat'))
load(fullfile(data_path, 'cleaned_downsampled_data.mat'))
disp('done')

cfg = [];
cfg.trials = cleaned_downsampled_data.trialinfo==8;
data = ft_selectdata(cfg, cleaned_downsampled_data);

%% Prepare data
cfg = [];
cfg.channel = 'meggrad';
cfg.latency = [-0.2 0.8];
data_slct = ft_selectdata(cfg, data);

cfg = [];
cfg.demean = 'yes';
cfg.baselinewindow = [-inf 0];
data_bs = ft_preprocessing(cfg, data_slct);

cfg = [];
cfg.covariance          = 'yes';
cfg.covariancewindow    = 'prestim';
evoked = ft_timelockanalysis(cfg, data_bs);

%% Get source space
% It is important that you use T1.mgz instead of orig.mgz as T1.mgz is normalized to [255,255,255] dimension
mridata_org     = fullfile(fs_subject_dir, '0177/mri/T1.mgz');
trans_org       = fullfile(data_path, '0177orig-trans.fif');
srcFname_org    = fullfile(data_path, 'orig-src.fif');

mridata_tmp     = fullfile(fs_subject_dir, '0177warp/mri/T1.mgz');
trans_tmp       = fullfile(data_path, '0177warp-trans.fif');
srcFname_tmp    = fullfile(data_path, 'warp-src.fif');

% Define outputs
srcOrg_outFname = fullfile(data_path, 'org_surf.mat');
srcTmp_outFname = fullfile(data_path, 'tmp_surf.mat');

mneOrg_outFname = fullfile(data_path, 'org_mne.mat');
mneTmp_outFname = fullfile(data_path, 'tmp_mne.mat');

%% Read transformation (head -> MRI)
% Orig
trans_orig = fiff_read_coord_trans(trans_org);
% In FieldTrip every thing is in head cordinate therefore in next line we are inverting the transformation
tra_org.trans=inv(trans_orig.trans);

% Template
trans_tmp = fiff_read_coord_trans(trans_tmp);
tra_tmp.trans=inv(trans_tmp.trans);

%% Read MRI (does not work on Win PC)
% Orig
mri_org = ft_read_mri(mridata_org);
mri_org = ft_convert_units(mri_org, 'cm');

% Template
mri_tmp = ft_read_mri(mridata_tmp);
mri_tmp = ft_convert_units(mri_tmp, 'cm');

%% The following lines are importing MNE coregistration to FieldTrip
% Orig
trans_orig.trans(1:3,4) = trans_orig.trans(1:3,4)*100;  % translation: meters to cm
To = mri_org.hdr.tkrvox2ras;                           % This is for FS T1.mgz!
To(1:3,:)=To(1:3,:)/10;

mri_org.transform = inv(trans_orig.trans)*(To);
mri_org = ft_determine_coordsys(mri_org, 'interactive', 'no');
mri_org.coordsys='neuromag';

% Template
trans_tmp.trans(1:3,4) = trans_tmp.trans(1:3,4)*100;  % translation: meters to cm
Tt = mri_tmp.hdr.tkrvox2ras;                            % This is for FS T1.mgz!
Tt(1:3,:) = Tt(1:3,:)/10;

mri_tmp.transform = inv(trans_tmp.trans)*(Tt);
mri_tmp = ft_determine_coordsys(mri_tmp, 'interactive', 'no');
mri_tmp.coordsys='neuromag';

%% Read potato
load(fullfile(data_path, 'headmodel_org.mat'));
load(fullfile(data_path, 'headmodel_tmp.mat'));

% vol = ft_read_headmodel(volname);
% headmodel = vol;
hm_org = ft_convert_units(headmodel_org,'m'); % Make sure units is in meters for transform
hm_tmp = ft_convert_units(headmodel_tmp,'m'); % Make sure units is in meters for transform

% Transform orig
headmodel_pos = hm_org.bnd.pos;
temp_vect = headmodel_pos;
temp_vect(:,4) = 1;
headmodel_pos = temp_vect*tra_org.trans';
hm_org.pos = headmodel_pos(:,1:3);
hm_org = ft_convert_units(hm_org, 'cm');  % Get back to cm

% Transform
headmodel_pos = hm_tmp.bnd.pos;
temp_vect = headmodel_pos;
temp_vect(:,4) = 1;
headmodel_pos = temp_vect*tra_tmp.trans';
hm_tmp.pos=headmodel_pos(:,1:3);
hm_tmp = ft_convert_units(hm_tmp, 'cm');  % Get back to cm

%% Reading FreeSurfer Source Space
src_org = ft_read_headshape(srcFname_org, 'format', 'mne_source');
src_tmp = ft_read_headshape(srcFname_tmp, 'format', 'mne_source');

% Transform orig
temp_vect = src_org.pos;
temp_vect(:,4) = 1;
src_pos = temp_vect*tra_org.trans';
src_pos = src_pos(:,1:3);

% Make source model orig
sm_org = src_org;
sm_org.pos = src_pos;
sm_org = ft_convert_units(sm_org, 'cm');
sm_org.inside = ones(length(sm_org.pos),1);

% Transform template
temp_vect = src_tmp.pos;
temp_vect(:,4) = 1;
src_pos=temp_vect*tra_tmp.trans';
src_pos=src_pos(:,1:3);

% Make source model template
sm_tmp = src_tmp;
sm_tmp.pos = src_pos;
sm_tmp = ft_convert_units(sm_tmp, 'cm');
sm_tmp.inside = ones(length(sm_tmp.pos),1);

%% Check coregistration
% Plot orig alignment
mri_org = ft_determine_coordsys(mri_org, 'interactive', 'no'); hold on;
% ft_plot_headshape(shape);
ft_plot_headmodel(hm_org, 'facealpha',0.25,'edgecolor', 'b','facecolor','b')
ft_plot_sens(evoked.grad, 'style', '*g','edgecolor','cyan');
ft_plot_mesh(sm_org, 'edgecolor','k')
view ([90 0])
title('MEG coregistration ORIG', 'FontSize', 13)

% Plot template alignment
mri_tmp = ft_determine_coordsys(mri_tmp, 'interactive', 'no'); hold on; 
ft_plot_headmodel(hm_tmp, 'facealpha',0.25,'edgecolor', 'b','facecolor','b')
ft_plot_sens(evoked.grad, 'style', '*g','edgecolor','cyan');
ft_plot_mesh(sm_tmp, 'edgecolor','k')
view ([90 0])
title('MEG coregistration TEMP', 'FontSize', 13);

%% Save stuff
disp('Saving...');
save(srcOrg_outFname, 'sm_org', '-v7.3');
save(srcTmp_outFname, 'sm_tmp', '-v7.3');
disp('DONE')

%% Leadfields
% cfg = [];
% cfg.covariance          = 'yes';
% cfg.covariancewindow    = 'all';
% cfg.channel             = 'MEG';
% data_cov = ft_timelockanalysis(cfg, evoked);
% 
% [u,s,v] = svd(data_cov.cov);
% d       = -diff(log10(diag(s)));
% d       = d./std(d);
% kappa   = find(d>5,1,'first');

% Original
cfg = [];
cfg.grad                = evoked.grad;     % sensor positions
cfg.channel             = 'meggrad';           % the used channels
cfg.senstype            = 'meg';
cfg.sourcemodel         = sm_org;          % source points
cfg.headmodel           = hm_org;          % volume conduction model
lf_org = ft_prepare_leadfield(cfg, evoked);

% Template
cfg.sourcemodel         = sm_tmp;          % source points
cfg.headmodel           = hm_tmp;          % volume conduction model
lf_tmp = ft_prepare_leadfield(cfg, evoked);

%% Do MNE
cfg                     = [];
cfg.method              = 'mne';
cfg.channel             = 'meggrad';
cfg.senstype            = 'meg';
cfg.mne.prewhiten       = 'yes';
cfg.mne.lambda          = 3;
cfg.mne.scalesourcecov  = 'yes';
cfg.sourcemodel         = lf_org;
cfg.headmodel           = hm_org;
mnesource_org  = ft_sourceanalysis(cfg, evoked);

cfg.sourcemodel         = lf_tmp;
cfg.headmodel           = hm_tmp;
mnesource_tmp  = ft_sourceanalysis(cfg, evoked);

%% Save source
disp('Saving...');
save(mneOrg_outFname, 'mnesource_org', '-v7.3');
save(mneTmp_outFname, 'mnesource_tmp', '-v7.3');
disp('DONE')

%% Inspect

cfg = [];
cfg.funparameter = 'pow';
ft_sourcemovie(cfg, mnesource_org);

cfg = [];
cfg.funparameter = 'pow';
figure; ft_sourcemovie(cfg, mnesource_tmp);

%%
cfg = [];
cfg.method          = 'surface';
cfg.funparameter    = 'pow';
cfg.funcolormap     = 'hot';    % Change for better color options
cfg.latency         = .10;     % The time-point to plot (s)
cfg.colorbar        = 'no';

ft_sourceplot(cfg, mnesource_org)
ft_sourceplot(cfg, mnesource_tmp)



















