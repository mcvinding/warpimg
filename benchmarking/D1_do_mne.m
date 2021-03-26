%% Comparison of MNE models
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Compute paths
% raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
% data_path = '/home/mikkel/mri_scripts/warpig/data/0177';
data_path = '/home/mikkel/mri_warpimg/data/0177';
fs_subject_dir = '/home/mikkel/mri_warpimg/fs_subjects_dir';
raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';

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
% transf_org      = fullfile(data_path, '0177orig-trans.fif');
% srcFname_org    = fullfile(data_path, 'orig-src.fif');

mridata_tmp     = fullfile(fs_subject_dir, '0177warp/mri/T1.mgz');
% transf_tmp      = fullfile(data_path, '0177warp-trans.fif');
% srcFname_tmp    = fullfile(data_path, 'warp-src.fif');

% Define outputs
srcOrg_outFname = fullfile(data_path, 'org_surf.mat');
srcTmp_outFname = fullfile(data_path, 'tmp_surf.mat');

mneOrg_outFname = fullfile(data_path, 'org_mne.mat');
mneTmp_outFname = fullfile(data_path, 'tmp_mne.mat');

%% Read transformation (head -> MRI)
% Orig
% trans_org = fiff_read_coord_trans(transf_org);
% % In FieldTrip every thing is in head cordinate therefore in next line we are inverting the transformation
% tra_org.trans=inv(trans_org.trans);
% 
% % Template
% trans_tmp = fiff_read_coord_trans(transf_tmp);
% tra_tmp.trans=inv(trans_tmp.trans);

%% Read MRI (does not work on Win PC)
% Orig
mri_org = ft_read_mri(mridata_org);
% mri_org = ft_convert_units(mri_org, 'cm');

% Template
mri_tmp = ft_read_mri(mridata_tmp);
% mri_tmp = ft_convert_units(mri_tmp, 'mm');

%% Reading FreeSurfer Source Space
srcFname_orgL = fullfile(fs_subject_dir, '0177/workbench/0177.L.white.4k_fs_LR.surf.gii');
srcFname_orgR = fullfile(fs_subject_dir, '0177/workbench/0177.R.white.4k_fs_LR.surf.gii');
src_org = ft_read_headshape({srcFname_orgL, srcFname_orgR}, 'format', 'gifti');
src_org = ft_determine_units(src_org);
src_org = ft_convert_units(src_org, 'mm');

srcFname_tmpL = fullfile(fs_subject_dir,'0177warp/workbench/0177warp.L.white.4k_fs_LR.surf.gii');
srcFname_tmpR = fullfile(fs_subject_dir,'0177warp/workbench/0177warp.R.white.4k_fs_LR.surf.gii');
src_tmp = ft_read_headshape({srcFname_tmpL, srcFname_tmpR}, 'format', 'gifti');
src_tmp = ft_determine_units(src_tmp);
src_tmp = ft_convert_units(src_tmp, 'mm');

%% Plot for inspection
ft_determine_coordsys(mri_org, 'interactive', 'no'); hold on;
ft_plot_mesh(src_org, 'edgecolor','k')

ft_determine_coordsys(mri_tmp, 'interactive', 'no'); hold on;
ft_plot_mesh(src_tmp, 'edgecolor','k')

%% Headpoints
rawfile     = fullfile(raw_folder, 'tactile_stim_raw_tsss_mc.fif');
headshape   = ft_read_headshape(rawfile);
grad        = ft_read_sens(rawfile,'senstype','meg'); % Load MEG sensors

% Make sure units are cm 
headshape = ft_convert_units(headshape, 'mm');
grad      = ft_convert_units(grad, 'mm');

%% Align
mri_org.coordsys = 'neuromag';
cfg = [];
cfg.method              = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp       = 'yes';
cfg.coordsys            = 'neuromag';
mri_org_realign2 = ft_volumerealign(cfg, mri_org);
% Inspect
% cfg.headshape.icp       = 'no';
% mri_org_realign3 = ft_volumerealign(cfg, mri_org_realign2);

mri_tmp.coordsys = 'neuromag';
cfg = [];
cfg.method              = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp       = 'yes';
cfg.coordsys            = 'neuromag';
mri_tmp_realign2 = ft_volumerealign(cfg, mri_tmp);
% Inspect
cfg.headshape.icp       = 'no';
mri_tmp_realign3 = ft_volumerealign(cfg, mri_tmp_realign2);

%% Reslice
mri_org_resliced = ft_volumereslice([], mri_org_realign2);
mri_tmp_resliced = ft_volumereslice([], mri_tmp_realign2);

%% Transform source spaces
To = mri_org_realign2.transform*inv(mri_org_realign2.transformorig);
surfsrc_org = ft_transform_geometry(To, src_org);

Tt = mri_tmp_realign2.transform*inv(mri_tmp_realign2.transformorig);
surfsrc_tmp = ft_transform_geometry(Tt, src_tmp)

%% Plot for inspection
ft_determine_coordsys(mri_org_resliced, 'interactive', 'no');  hold on;
ft_plot_mesh(surfsrc_org, 'edgecolor','k')
ft_plot_headshape(headshape)
ft_plot_sens(grad, 'edgecolor','b')

ft_determine_coordsys(mri_tmp_resliced, 'interactive', 'no');  hold on;
ft_plot_mesh(surfsrc_tmp, 'edgecolor','k')
ft_plot_headshape(headshape)
ft_plot_sens(grad, 'edgecolor','b')

%% Segment inner volume of MRI.
cfg = [];
cfg.output = 'brain';
mri_org_seg = ft_volumesegment(cfg, mri_org_resliced);
mri_tmp_seg = ft_volumesegment(cfg, mri_tmp_resliced);

% % Save 
% save(fullfile(data_path, 'mri_tmp_seg.mat'), 'mri_tmp_seg')
% save(fullfile(data_path, 'mri_org_seq.mat'), 'mri_org_seg')

%% Plot segmentations for inspection
mri_org_seg.anatomy = mri_org_resliced.anatomy;
mri_tmp_seg.anatomy = mri_tmp_resliced.anatomy;

cfg = [];
cfg.anaparameter = 'anatomy';
cfg.funparameter = 'brain';
ft_sourceplot(cfg, mri_org_seg);
ft_sourceplot(cfg, mri_tmp_seg);

% Plot both segmentations on original volume
pltvol = mri_org_resliced;
pltvol.brain = mri_tmp_seg.brain+mri_org_seg.brain;

cfg.anaparameter = 'anatomy';
cfg.funparameter = 'brain';
ft_sourceplot(cfg, pltvol);

%% STEP 2D: Construct mesh from inner volume and create the headmodel
cfg = [];
cfg.method      = 'projectmesh';
cfg.tissue      = 'brain';
cfg.numvertices = 3000;
mesh_brain_org = ft_prepare_mesh(cfg, mri_org_seg);
mesh_brain_tmp = ft_prepare_mesh(cfg, mri_tmp_seg);

cfg = [];
cfg.method = 'singleshell';
headmodel_org = ft_prepare_headmodel(cfg, mesh_brain_org);
headmodel_tmp = ft_prepare_headmodel(cfg, mesh_brain_tmp);

%% Plot for inspection
ft_determine_coordsys(mri_org_resliced, 'interactive', 'no');  hold on;
ft_plot_mesh(surfsrc_org, 'edgecolor','k')
% ft_plot_headshape(headshape)
ft_plot_sens(grad, 'edgecolor','b')
ft_plot_headmodel(headmodel_org, 'edgecolor','c','facealpha',0.25)

ft_determine_coordsys(mri_tmp_resliced, 'interactive', 'no');  hold on;
ft_plot_mesh(surfsrc_tmp, 'edgecolor','k')
% ft_plot_headshape(headshape)
ft_plot_sens(grad, 'edgecolor','b')
ft_plot_headmodel(headmodel_tmp, 'edgecolor','c','facealpha',0.25)

%% Save stuff
% Save headmodels
fprintf('Saving...')
save(fullfile(data_path, 'headmodel_mne_tmp.mat'), 'headmodel_tmp')
save(fullfile(data_path, 'headmodel_mne_org.mat'), 'headmodel_org')
save(srcOrg_outFname, 'surfsrc_org', '-v7.3');
save(srcTmp_outFname, 'surfsrc_tmp', '-v7.3');
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
cfg.sourcemodel         = surfsrc_org;          % source points
cfg.headmodel           = headmodel_org;          % volume conduction model
lf_org = ft_prepare_leadfield(cfg, evoked);

% Template
cfg.sourcemodel         = surfsrc_tmp;          % source points
cfg.headmodel           = headmodel_tmp;          % volume conduction model
lf_tmp = ft_prepare_leadfield(cfg, evoked);

%% Do MNE (with grads)
cfg                     = [];
cfg.method              = 'mne';
cfg.channel             = 'meggrad';
cfg.senstype            = 'meg';
cfg.mne.prewhiten       = 'yes';
cfg.mne.lambda          = 3;
cfg.mne.scalesourcecov  = 'yes';
cfg.sourcemodel         = lf_org;
cfg.headmodel           = headmodel_org;
mnesource_org  = ft_sourceanalysis(cfg, evoked);

cfg.sourcemodel         = lf_tmp;
cfg.headmodel           = headmodel_tmp;
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

%% Plot
cfg = [];
cfg.method          = 'surface';
cfg.funparameter    = 'pow';
cfg.funcolormap     = 'jet';    % Change for better color options
cfg.latency         = .100;     % The time-point to plot (s)
cfg.colorbar        = 'no';

tst = mnesource_org;
tst.avg.pow = log(mnesource_tmp.avg.pow./mnesource_org.avg.pow);

ft_sourceplot(cfg, mnesource_org); title('Orig MRI')
ft_sourceplot(cfg, mnesource_tmp); title('Warped template MRI')
ft_sourceplot(cfg, tst); title('Log-ratio')


% How to compare when sposition is different between source models

















