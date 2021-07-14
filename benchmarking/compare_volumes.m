%% Comparison of volume headmodels
% 
% <<REF>>
%
% Get summary statistics of the warped template and original MRI
% headmodels. Do similarity comparison of the brainmask. Plot the
% headmodels superimposed (Figure 3).
% Analyse the similarity in atlas label location in volume.

addpath('~/fieldtrip/fieldtrip/')
ft_defaults
addpath('~/reliability_analysis/') % https://github.com/mcvinding/reliability_analysis


%% Paths
subjs = {'0177'};

data_path = '/home/mikkel/mri_warpimg/data/0177';
out_path = '/home/mikkel/mri_warpimg/figures';
ft_path   = '~/fieldtrip/fieldtrip/';

%% Load headmodels
% Add a loop over files when testing
load(fullfile(data_path, 'headmodel_tmp.mat'))
load(fullfile(data_path, 'headmodel_org.mat'))

%% Convert to cm for more easy intrepretation of volumes
headmodel_tmp = ft_convert_units(headmodel_tmp, 'mm');
headmodel_org = ft_convert_units(headmodel_org, 'mm');

%% Get volume and surface area
[~, v_org] = convhull(headmodel_org.bnd.pos);
[~, v_tmp] = convhull(headmodel_tmp.bnd.pos);

pct_dv = (v_org-v_tmp)/v_org*100

asurf_org = surfaceArea(alphaShape(headmodel_org.bnd.pos));
asurf_tmp = surfaceArea(alphaShape(headmodel_tmp.bnd.pos));

pct_dasurf = (asurf_org-asurf_tmp)/asurf_org*100

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

print(fullfile(out_path, 'headmodels.png'), '-dpng')

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