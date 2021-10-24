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

%% Paths
data_path = '/home/mikkel/mri_warpimg/data/0177/170424';
out_path = '/home/mikkel/mri_warpimg/figures';
ft_path   = '~/fieldtrip/fieldtrip/';

%% Load MRIs
load standard_mri                                       % Load Colin 27
mri_colin = mri;                                        % Rename to avoid confusion
load(fullfile(data_path, 'mri_org_resliced.mat'));      % original subject MRI
load(fullfile(data_path, 'mri_warptmp.mat'));           % Warped template MRI

%% Segment
cfg = [];
cfg.output      = 'tpm';
cfg.spmmethod   = 'new';
mri_org_seg = ft_volumesegment(cfg, mri_org_resliced);
mri_tmp_seg = ft_volumesegment(cfg, mri_warptmp);
mri_col_seg = ft_volumesegment(cfg, mri_colin);

mri_tmp_seg.anatomy = mri_tmp_resliced.anatomy;
mri_org_seg.anatomy = mri_org_resliced.anatomy;
mri_col_seg.anatomy = mri_colin.anatomy;

disp('done all')

%% Summaries
ft_checkdata(mri_org_seg, 'feedback', 'yes');
ft_checkdata(mri_tmp_seg, 'feedback', 'yes');
ft_checkdata(mri_col_seg, 'feedback', 'yes');

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

%% Atlas comparison
% Read atlas, source models, and MRIs
atlas = ft_read_atlas(fullfile(ft_path, '/template/atlas/aal/ROI_MNI_V4.nii'));
load(fullfile(ft_path, 'template/sourcemodel/standard_sourcemodel3d6mm'));
load(fullfile(data_path, 'sourcemodels_mni.mat'));
load(fullfile(data_path,'mri_org_resliced'));
load(fullfile(data_path,'mri_warptmp'));
load(fullfile(data_path, 'mri_tmp_seg.mat'))
load(fullfile(data_path, 'mri_org_seg.mat'))

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

% Interpolate atlas for original and warped template onto original anatomy
cfg = [];
cfg.parameter       = 'tissue';
cfg.interpmethod    = 'nearest'; 
atlasintp_org = ft_sourceinterpolate(cfg, sourcemodel_org, mri_org_resliced);
atlasintp_tmp = ft_sourceinterpolate(cfg, sourcemodel_tmp, mri_org_resliced);

% Remove "air"
atlasintp_org.tissue(atlasintp_org.tissue==0) = nan;
atlasintp_tmp.tissue(atlasintp_tmp.tissue==0) = nan;

cfg = [];
cfg.funparameter    = 'tissue';
cfg.funcolormap     = 'hsv';
cfg.opacitylim     = [1, max(sourcemodel_org.tissue)];
cfg.colorbar        = 'no';
% cfg.method          = 'surface';
ft_sourceplot(cfg, atlasintp_org)
ft_sourceplot(cfg, atlasintp_tmp)

%% Similarity analysis
addpath('~/reliability_analysis/') % https://github.com/mcvinding/reliability_analysis

% Prepare data: remove voxels outside the brain
x = atlasintp_org.tissue(mri_org_seg.brain==1);
y = atlasintp_tmp.tissue(mri_org_seg.brain==1);

dat = [x'; y'];

fprintf('Calculating alpha... ')
a_atlas = kripAlpha(dat, 'nominal', 1);
disp('done')

%END