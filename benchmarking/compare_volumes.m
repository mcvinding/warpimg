%% Comparison of volume headmodels
% 
% <<REF>>
%
% Get summary statistics of the warped template and original MRIs. 
% Run SPM segmentation and get volumes of compartments to compare.
% Do similarity comparison of the brainmask. Plot the headmodels superimposed 
% (Figure 3) Analyse the similarity in atlas label location in volume.

addpath('~/fieldtrip/fieldtrip/')
ft_defaults
addpath('~/reliability_analysis/') % https://github.com/mcvinding/reliability_analysis

%% Paths
subjs = {'0177'};

data_path = '/home/mikkel/mri_warpimg/data/0177';
out_path = '/home/mikkel/mri_warpimg/figures';
ft_path   = '~/fieldtrip/fieldtrip/';

%% Load MRIs
load standard_mri                                   % Load Colin 27
mri_colin = mri;                                    % Rename to avoid confusion
load(fullfile(data_path, 'mri_tmp_resliced.mat'));  % Warped template MRI
load(fullfile(data_path, 'mri_org_resliced.mat'));  % original subject MRI
load(fullfile(data_path, 'mri_tmp_resliced3.mat'));  % Warped template MRI

%% Segment
cfg = [];
cfg.output      = 'tpm';
cfg.spmmethod   = 'new';
mri_tmp_seg  = ft_volumesegment(cfg, mri_tmp_resliced);
mri_tmp2_seg = ft_volumesegment(cfg, mri_tmp_resliced2);
mri_tmp3_seg = ft_volumesegment(cfg, mri_warp2neuromag2);
mri_org_seg  = ft_volumesegment(cfg, mri_org_resliced);
mri_col_seg = ft_volumesegment(cfg, mri_colin);

mri_tmp_seg.anatomy  = mri_tmp_resliced.anatomy;
mri_org_seg.anatomy  = mri_org_resliced.anatomy;
mri_tmp2_seg.anatomy = mri_tmp_resliced2.anatomy;
mri_tmp3_seg.anatomy = mri_warp2neuromag2.anatomy;
mri_col_seg.anatomy = mri_colin.anatomy;

disp('done all')

%%
cfg = [];
cfg.funparameter  = 'anatomy';
cfg.maskparameter = 'bone';
ft_sourceplot(cfg, mri_org_seg)
ft_sourceplot(cfg, mri_tmp_seg)
ft_sourceplot(cfg, mri_tmp2_seg)
ft_sourceplot(cfg, mri_tmp3_seg)

%% Summaries
ft_checkdata(mri_org_seg, 'feedback', 'yes');
ft_checkdata(mri_tmp_seg, 'feedback', 'yes');
ft_checkdata(mri_tmp2_seg, 'feedback', 'yes');
ft_checkdata(mri_tmp3_seg, 'feedback', 'yes');
% ft_checkdata(mri_col_seg, 'feedback', 'yes');

%% Manual
% Gray
gryvol_tmp = sum(mri_tmp_seg.gray(:))/1000;
gryvol_org = sum(mri_org_seg.gray(:))/1000;
gryvol_col = sum(mri_col_seg.gray(:))/1000;

% White
whtvol_tmp = sum(mri_tmp_seg.white(:))/1000;
whtvol_org = sum(mri_org_seg.white(:))/1000;
whtvol_col = sum(mri_col_seg.white(:))/1000;

% CSF
csfvol_tmp = sum(mri_tmp_seg.csf(:))/1000;
csfvol_org = sum(mri_org_seg.csf(:))/1000;
csfvol_col = sum(mri_col_seg.csf(:))/1000;

% sum
totvol_tmp = gryvol_tmp + whtvol_tmp + csfvol_tmp;
totvol_org = gryvol_org + whtvol_org + csfvol_org;
totvol_col = gryvol_col + whtvol_col + csfvol_col;

%% Comparison
(gryvol_tmp-gryvol_org)/gryvol_org*100
(whtvol_tmp-whtvol_org)/whtvol_org*100
(csfvol_tmp-csfvol_org)/csfvol_org*100
(totvol_tmp-totvol_org)/totvol_org*100

%% Plot
cfg = [];
cfg.funparameter = 'white';
ft_sourceplot(cfg, mri_tmp_seg)
ft_sourceplot(cfg, mri_org_seg)
ft_sourceplot(cfg, mri_col_seg)

cfg = [];
cfg.funparameter = 'gray';
ft_sourceplot(cfg, mri_tmp_seg)
ft_sourceplot(cfg, mri_org_seg)
ft_sourceplot(cfg, mri_col_seg)

cfg = [];
cfg.funparameter = 'csf';
ft_sourceplot(cfg, mri_tmp_seg)
ft_sourceplot(cfg, mri_org_seg)
ft_sourceplot(cfg, mri_col_seg)

%% Load headmodels
load(fullfile(data_path, 'headmodel_tmp.mat'))
load(fullfile(data_path, 'headmodel_org.mat'))

%% Plot headmodels
figure; set(gcf,'Position',[0 0 1200 400]); hold on

subplot(1,3,1); hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.2, 'facecolor', 'c')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
view([0 1 0]); title('Coronal')

subplot(1,3,2); hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.2, 'facecolor', 'c')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
view([1 0 0]); title('Sagittal')

subplot(1,3,3); hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.2, 'facecolor', 'c')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'r')
view([0 0 1]); title('Axial')

% print(fullfile(out_path, 'headmodels.png'), '-dpng')

%% Compare brainmasks
fprintf('loading data... ')
load(fullfile(data_path,'mri_orig_seg.mat'))
load(fullfile(data_path,'mri_tmp_seg.mat'))
disp('done')

x = mri_orig_seg.brain(:);
y = mri_tmp_seg.brain(:);

dat = [x'; y'];

fprintf('Calculating alpha... ')
a_brainmask = kripAlpha(dat, 'nominal');
disp('done')

save(fullfile(data_path,'a_brainmask'), 'a_brainmask')

%% Reload alpha
% load(fullfile(data_path,'a_brainmask'))

%% Atlas comparison
% Read atlas, source models, and MRIs
atlas = ft_read_atlas(fullfile(ft_path, '/template/atlas/aal/ROI_MNI_V4.nii'));
load(fullfile(ft_path, 'template/sourcemodel/standard_sourcemodel3d6mm'));
load(fullfile(data_path, 'sourcemodels_mni.mat'));
load(fullfile(data_path,'mri_org_resliced'));
load(fullfile(data_path,'mri_tmp_resliced'));

sourcemodel = ft_convert_units(sourcemodel, 'mm');
mri_org_resliced.anatomy(mri_org_resliced.anatomy>5000) = 5000;

% Add atlas info to sources
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter    = 'tissue';
tmp = ft_sourceinterpolate(cfg, atlas, sourcemodel);
tmp.tissuelabel = atlas.tissuelabel;

atlas_grid = ft_checkdata(tmp, 'datatype', 'source');
atlas_grid.inside = sourcemodel.inside;

% add atlas to source points
sourcemodel_org.tissue = atlas_grid.tissue;
sourcemodel_org.tissuelabel = atlas_grid.tissuelabel;
sourcemodel_tmp.tissue = atlas_grid.tissue;
sourcemodel_tmp.tissuelabel = atlas_grid.tissuelabel;

% Interpolate atals to MRI
cfg = [];
cfg.parameter       = 'tissue';
cfg.interpmethod    = 'nearest'; 
atlasintp_org = ft_sourceinterpolate(cfg, sourcemodel_org, mri_org_resliced);
atlasintp_tmp = ft_sourceinterpolate(cfg, sourcemodel_tmp, mri_tmp_resliced);

% Remove "air"
atlasintp_org.tissue(~mri_orig_seg.brain) = nan;
atlasintp_tmp.tissue(~mri_tmp_seg.brain) = nan;

cfg = [];
cfg.funparameter    = 'tissue';
cfg.funcolormap     = 'hsv';
cfg.opacitylim     = [1, max(sourcemodel_org.tissue)];
cfg.colorbar        = 'no';
% cfg.method          = 'surface';
ft_sourceplot(cfg, atlasintp_org)
ft_sourceplot(cfg, atlasintp_tmp)

%% Similarity analysis

x = atlasintp_org.tissue(:);
y = atlasintp_tmp.tissue(:);

dat = [x'; y'];

fprintf('Calculating alpha... ')
a_atlas = kripAlpha(dat, 'nominal');
disp('done')

%END