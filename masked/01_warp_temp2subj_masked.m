%% Warp template MRI to subject MRI for creating source model
%
% <ref>
%
% Import orignal MRI, align to MEG coordinate system and export as SPM 
% readable file. Import template (Colin) and "normalize" the template to
% the original MRI. This example use a mask to stratisfy the warping. Save 
% and export.

%% Paths
% Change these paths to match you system and project setup.
if ispc
    raw_folder = 'Y:/workshop_source_reconstruction/20180206';
    out_folder = 'Z:/mri_warpimg/data';
    ftpath = 'C:\fieldtrip';
else
    raw_folder = '/home/share/workshop_source_reconstruction/20180206';
    out_folder = '/home/mikkel/mri_warpimg/data/';
    ftpath = '/home/mikkel/fieldtrip/fieldtrip';
end
addpath(ftpath)
ft_defaults 

%Subjects
% Make a loop here for multiple subjects
subjs = {'0177'};

% Paths
mri_path = fullfile(raw_folder, 'MRI', 'dicoms');                       % Raw data folder
meg_path = fullfile(raw_folder, 'MEG', ['NatMEG_',subjs{1}], '170424'); % Raw data folder
sub_path = fullfile(out_folder, subjs{1});                              % Output folder

%% STEP 1A: Load subject MRI

%% STEP 2: Convert subject MRI to desired coordinate system

%% Step 2A: Convert to Neuromag coordinate system

%% Step 2B: Align MRI and MEG headpoints in MEG coordinate system (neuromag)

%% Step 2C: Reslice aligned image
% Reslice to new coordinate system
mri_org_resliced = ft_volumereslice([], mri_org_realign);

fprintf('saving...');
save(fullfile(sub_path,'mri_org_resliced'), 'mri_org_resliced');
disp('done')

%% Step 2D: Write subject volume as the "template". 
% The template anatomy should always be stored in a SPM-compatible file (i.e.
% NIFTI).
% (re)load data
load(fullfile(sub_path,'mri_org_resliced')); disp('done')

%% Write Neuromag image
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.datatype    = 'double';
cfg.filename    = fullfile(sub_path, 'orig_neuromag_rs');   % Same base filename but different format
ft_volumewrite(cfg, mri_org_resliced)

%% Step 2E: Make and save brainmask with template
cfg = [];
cfg.output = 'brain';
org_seq = ft_volumesegment(cfg, mri_org_resliced);

cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'brain';
cfg.datatype    = 'double';
cfg.filename    = fullfile(sub_path, 'orig_mask');   % Same base filename but different format
ft_volumewrite(cfg, org_seq)

%% STEP 3: warp a template MRI to the individual MRI "template"
% In this example, we load the Colin27 template (https://www.mcgill.ca/bic/software/tools-data-analysis/anatomical-mri/atlases/colin-27),
% which comes as the standard_mri in FieldTrip. Then use ft_volumenormalise
% to "normalise" the Colin27 template to the indivdual anatomical "template"
% created above.

% Load template MRI
load standard_mri           % Load Colin 27
mri_colin = mri;            % Rename to avoid confusion

%% Step 3A: Do initial alignmet of fiducials to target coordsys (optional)
% For better precision (e.g. if using non-standard fiducials).
cfg = [];
cfg.method      = 'interactive';
cfg.coordsys    = 'neuromag';
mri_colin_neuromag = ft_volumerealign(cfg, mri_colin);     

%% Make brainmask for the template
cfg = [];
cfg.output = 'brain';
col_seq = ft_volumesegment(cfg, mri_colin_neuromag);

mri_colin_neuromag.inside = col_seq.brain;

%% Step 3B: Normalise template -> subject (neuromag coordsys)
cfg = [];
cfg.nonlinear        = 'yes';       % Non-linear warping
cfg.spmmethod        = 'old';       % Note: method = "new" will only use SPM's default posterior tissue maps.
cfg.spmversion       = 'spm12';     % Default = "spm12"
cfg.templatecoordsys = 'neuromag';  % Coordinate system of the template
cfg.template         = fullfile(sub_path,'orig_neuromag_rs.nii'); % #Template created in step 2D
cfg.templatemask     = fullfile(sub_path,'orig_mask.nii');
mri_warp2neuromag2 = ft_volumenormalise2(cfg, mri_colin_neuromag);

% Determine unit of volume (mm)
mri_warp2neuromag2 = ft_determine_units(mri_warp2neuromag2);

% Plot for inspection
ft_sourceplot([], mri_warp2neuromag2); title('Warped2neuromag2')

% Save
saveas(gcf, fullfile(sub_path, ['template2', cfg.templatecoordsys,'.pdf']))
close

%% Save
% Renaming for filename consitency (optional -> not recommeded)
mri_tmp_resliced2 = mri_warp2neuromag2;

% Save
fprintf('saving...')
save(fullfile(sub_path,'mri_tmp_resliced2'), 'mri_tmp_resliced2')
disp('done')

%% Preapre for Freesurfer
% Save in mgz format in a Freesurfer subject directory to run Freesurfer's
% recon-all later (only works on Linux). Here it saves both the original
% and the warped template for comparison.
load(fullfile(sub_path, 'mri_tmp_resliced2.mat'))

% Freesurfer $SUBJECTS_DIR path
fs_subjdir = '/home/mikkel/mri_warpimg/fs_subjects_dir/';

% Warped 2
cfg = [];
cfg.filename    = fullfile(fs_subjdir, '0177warp2', 'mri','orig', '001');
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
cfg.datatype    = 'double';
ft_volumewrite(cfg, mri_tmp_resliced2);

% END