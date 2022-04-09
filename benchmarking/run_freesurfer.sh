## RUN FREESURFER
# Test if Freesurfer (https://freesurfer.net/) can run on warped templates.

export SUBJECTS_DIR='~/mri_warpimg/fs_subjects_dir'
recon-all -all -subjid 0177
recon-all -all -subjid 0177warp
recon-all -all -subjid colin
echo 'done'

#END