%% MNE source reconstruction
%
% <<REF>>
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
addpath '~/fieldtrip/fieldtrip/external/mne'

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177';
fs_subject_dir = '/home/mikkel/mri_warpimg/fs_subjects_dir';
raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';

% Output filenames
mneOrg_outFname = fullfile(data_path, 'mnesource_org.mat');
mneTmp_outFname = fullfile(data_path, 'mnesource_tmp.mat');

%% Load data
fprintf('Loading... ')
load(fullfile(data_path, 'epo.mat'));
disp('done')

%% Get source space
% It is important that you use T1.mgz instead of orig.mgz as T1.mgz is 
% normalized to [255,255,255] dimension
mridata_org     = fullfile(fs_subject_dir, '0177/mri/T1.mgz');
mridata_tmp     = fullfile(fs_subject_dir, '0177warp/mri/T1.mgz');

% Read MRI (does not work on Win PC)
mri_org = ft_read_mri(mridata_org);
mri_tmp = ft_read_mri(mridata_tmp);

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
cfg.headshape.icp       = 'no';
mri_org_realign3 = ft_volumerealign(cfg, mri_org_realign2);

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
surfsrc_tmp = ft_transform_geometry(Tt, src_tmp);

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

%% Construct mesh from inner volume and create the headmodel
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
cfg.grad                = evoked.grad;     % sensor positions
cfg.channel             = 'meg';          % the used channels
cfg.senstype            = 'meg';

% Original
cfg.sourcemodel         = surfsrc_org;          % source points
cfg.headmodel           = headmodel_org;          % volume conduction model
lf_org = ft_prepare_leadfield(cfg, evoked);

% Template
cfg.sourcemodel         = surfsrc_tmp;          % source points
cfg.headmodel           = headmodel_tmp;          % volume conduction model
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
figure; ft_sourcemovie(cfg, mnesource_tmp);

%% Save source
fprintf('Saving...');
save(mneOrg_outFname, 'mnesource_org', '-v7.3');
save(mneTmp_outFname, 'mnesource_tmp', '-v7.3');
disp('done')

%END