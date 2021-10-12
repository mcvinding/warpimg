%% Warp template MRI to subject MRI for creating source model
%
% <ref>
%
% Import orignal MRI, align to MEG coordinate system and export as SPM 
% readable file. Import template (Colin) and "normalize" the template to
% the original MRI. Save and export.

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
subjs = {'0177'}; ss = 1;

% Paths
mri_path = fullfile(raw_folder, 'MRI', 'dicoms');                       % Raw data folder
meg_path = fullfile(raw_folder, 'MEG', ['NatMEG_',subjs{ss}], '170424'); % Raw data folder
sub_path = fullfile(out_folder, subjs{ss});                              % Output folder

%% STEP 1A: Load subject MRI
% Load the subject anatomical image. Determine coordinate systen (ras, origin not
% a landmark).

% Read MRI
raw_fpath = fullfile(mri_path, '00000001.dcm');
mri_orig = ft_read_mri(raw_fpath);

% Define coordinates of raw (r-a-s-n)
mri_orig = ft_determine_coordsys(mri_orig, 'interactive', 'yes');

%Save
save(fullfile(sub_path, 'mri_orig.mat'), 'mri_orig')

%% STEP 2: Convert subject MRI to desired coordinate system
% Convert to the desired coordinate system. In this example, we convert to
% the "neuromag" coordinate system used by MEGIN Neruomag MEG scanners. 
% Commonly used coordinate systems in MEG data analysis: acpc, neuromag, and 
% cft (depending on the MEG manufacutre). For information on the different
% coordinate % systems see: http://www.fieldtriptoolbox.org/faq/how_are_the_different_head_and_mri_coordinate_systems_defined/

% (Re)load data
load(fullfile(sub_path, 'mri_orig.mat'))

%% Step 2A: Convert to Neuromag coordinate system
cfg = [];
cfg.method      = 'interactive';
cfg.coordsys    = 'neuromag';
mri_neuromag = ft_volumerealign(cfg, mri_orig);       

% Not that if it gives warnings about left/right it might lead to erros

%% Step 2B: Align MRI and MEG headpoints in MEG coordinate system (neuromag)
% Align the MRI with the headpoints measures at the MEG recording. In this
% example we use headpoints from a Neuromag MEG dataset.

% Get headshapes and sensor info from MEG file
rawfile     = fullfile(meg_path, 'tactile_stim_raw_tsss_mc.fif'); % Name of datafile with sensor and head points.
headshape   = ft_read_headshape(rawfile);

% Make sure units are mm
headshape = ft_convert_units(headshape, 'mm');

% Save headshapes and sensor info (optional)
save(fullfile(data_path, 'headshape'), 'headshape')

% Aligh MRI to MEG headpoints
cfg = [];
cfg.method              = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp       = 'yes';
cfg.coordsys            = 'neuromag';
mri_org_realign = ft_volumerealign(cfg, mri_neuromag);

% Inspection (plot only)
cfg.headshape.icp = 'no';
ft_volumerealign(cfg, mri_org_realign);

% Save
save(fullfile(data_path, 'mri_org_realign'), 'mri_org_realign')
disp('done')

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
load(fullfile(sub_path,'mri_org_resliced'));

%% Write Neuromag image
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.datatype    = 'double';
cfg.filename    = fullfile(sub_path, 'orig_neuromag_rs');   % Same base filename but different format
ft_volumewrite(cfg, mri_org_resliced)

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

%% Step 3B: Normalise template -> subject (neuromag coordsys)
cfg = [];
cfg.nonlinear        = 'yes';       % Non-linear warping
cfg.spmmethod        = 'old';       % Note: method = "new" will only use SPM's default posterior tissue maps.
cfg.spmversion       = 'spm12';     % Default = "spm12"
cfg.templatecoordsys = 'neuromag';  % Coordinate system of the template
cfg.template         = fullfile(sub_path,'orig_neuromag_rs.nii'); % #Template created in step 2D

mri_warp2neuromag = ft_volumenormalise(cfg, mri_colin_neuromag);

% Determine unit of volume (mm)
mri_warp2neuromag = ft_determine_units(mri_warp2neuromag);

% Plot for inspection
ft_sourceplot([], mri_warp2neuromag); title('Warped2neuromag')

% Save
saveas(gcf, fullfile(sub_path, ['template', cfg.templatecoordsys,'.pdf']))
close

%% Save
% Renaming for filename consitency (optional -> not recommeded)
mri_tmp_resliced = mri_warp2neuromag;

% Save
fprintf('saving...')
save(fullfile(sub_path,'mri_tmp_resliced'), 'mri_tmp_resliced')
disp('done')

%% Conclusion 
% From here on, you can use the warped template to create headmodels and 
% source spaces as demonstrated in example scripts 02 and 03. If you want
% to run Freesurfer, use the code below to export to Freesurfer file format
% and continue to run Freesurfer.

%% Preapre for Freesurfer
% Save in mgz format in a Freesurfer subject directory to run Freesurfer's
% recon-all later (only works on Linux). Here it saves both the original
% and the warped template for comparison.
load(fullfile(sub_path, 'mri_tmp_resliced.mat'))
load(fullfile(sub_path, 'mri_org_resliced.mat'))

% (re)load template MRI
% This is only used to compare to the Freesurfer results from orignal MRI
% and the warped template.
load standard_mri           % Load Colin 27
mri_colin = mri;            % Rename to avoid confusion

% Freesurfer $SUBJECTS_DIR path
fs_subjdir = '/home/mikkel/mri_warpimg/fs_subjects_dir/';

% Warped
cfg = [];
cfg.filename    = fullfile(fs_subjdir, '0177warp3', 'mri','orig', '001');
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
cfg.datatype    = 'double';
ft_volumewrite(cfg, mri_tmp_resliced);

% Original
cfg = [];
cfg.filename    = fullfile(fs_subjdir, '0177', 'mri','orig', '001');
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
cfg.datatype    = 'double';
ft_volumewrite(cfg, mri_org_resliced);

% Original template
cfg = [];
cfg.filename    = fullfile(fs_subjdir, 'colin', 'mri','orig', '001');
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
cfg.datatype    = 'uint8';
ft_volumewrite(cfg, mri_colin);

% END