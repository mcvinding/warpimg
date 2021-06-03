## RUN FREESURFER
export SUBJECTS_DIR='/home/mikkel/mri_warpimg/fs_subjects_dir'
recon-all -all -subjid 0177
recon-all -all -subjid 0177warp
recon-all -all -subjid colin
echo 'done'
