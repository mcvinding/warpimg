%% Prepare MEG data



raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
data_path = '/home/mikkel/mri_warpimg/data/';


load(fullfile(raw_folder,'cleaned_downsampled_data.mat'))


cfg         = [];
cfg.trials  = cleaned_downsampled_data.trialinfo==4;
epo = ft_selectdata(cfg, cleaned_downsampled_data);

save(fullfile(data_path, 'epo.mat'))