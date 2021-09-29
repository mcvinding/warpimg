# Run ft_postfreesurferscript
#
# Must have the HCP toolbox added to PATH to run.
#
# The script ft_postfreesurferscript has been copied from FieldTrip to the project directory
# to keep the processing toghether.

export HCPPIPEDIR=/home/mikkel/HCPipelines/
export SUBJECTS_DIR='/home/mikkel/mri_warpimg/fs_subjects_dir'
export TEMPLATE_DIR='/home/mikkel/HCPipelines/HCPpipelines/global/templates/standard_mesh_atlases'

#/home/mikkel/mri_warpimg/ft_postfreesurferscript.sh $SUBJECTS_DIR 0177 $TEMPLATE_DIR
/home/mikkel/mri_warpimg/ft_postfreesurferscript.sh $SUBJECTS_DIR 0177warp2 $TEMPLATE_DIR

#END
