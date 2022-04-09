# Run ft_postfreesurferscript to prepare Freesurfer surfaces for MNE source reconstruction.
#
# Must have the HCP toolbox added to PATH to run (https://www.humanconnectome.org/software/).
#
# The script ft_postfreesurferscript is part of FieldTrip and found in fieldtrip/bin/ft_postfreesurferscript

export HCPPIPEDIR=~/HCPipelines/
export SUBJECTS_DIR='~/mri_warpimg/fs_subjects_dir'
export TEMPLATE_DIR='~/HCPipelines/HCPpipelines/global/templates/standard_mesh_atlases'

#~/fieldtrip/fieldtrip/bin/ft_postfreesurferscript.sh $SUBJECTS_DIR 0177 $TEMPLATE_DIR
~/fieldtrip/fieldtrip/bin/ft_postfreesurferscript.sh $SUBJECTS_DIR 0177warp $TEMPLATE_DIR

#END
