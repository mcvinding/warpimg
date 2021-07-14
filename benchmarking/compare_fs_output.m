%% Compare Freesurfer summaries of MRIs
% 
% <<REF>>
%
% Read Freesurfer output stat files and compare the similarity between the
% original MRI, the warped template, and the unmodified Colin27 template.
% Incl. plots. Stats files from Freesurfer has been manually convertet from
% .stats to .txt.

out_path = '/home/mikkel/mri_warpimg/figures';

% Variable names
varnam = {'StructName' 'NumVert' 'SurfArea' 'GrayVol' 'ThickAvg' 'ThickStd' 'MeanCurv' 'GausCurv' 'FoldInd' 'CurvInd'};

%% Read and arragne data: Original MRI
dat_lh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/0177/stats/lh.aparc.a2009s.txt') ;
dat_rh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/0177/stats/rh.aparc.a2009s.txt') ;

dat_lh.Properties.VariableNames = varnam;
dat_rh.Properties.VariableNames = varnam;

for ii = 1:height(dat_lh)
    dat_lh.StructName{ii} = [dat_lh.StructName{ii},'_lh'];
    dat_rh.StructName{ii} = [dat_rh.StructName{ii},'_rh'];
end

fs_dat_org = [dat_lh; dat_rh];

%% Read and arragne data: Warped template
dat_lh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/0177warp/stats/lh.aparc.a2009s.txt') ;
dat_rh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/0177warp/stats/rh.aparc.a2009s.txt') ;

dat_lh.Properties.VariableNames = varnam;
dat_rh.Properties.VariableNames = varnam;

for ii = 1:height(dat_lh)
    dat_lh.StructName{ii} = [dat_lh.StructName{ii},'_lh'];
    dat_rh.StructName{ii} = [dat_rh.StructName{ii},'_rh'];
end

fs_dat_tmp = [dat_lh; dat_rh];

%% Read and arragne data: Unmodified template
dat_lh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/colin/stats/lh.aparc.a2009s.txt') ;
dat_rh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/colin/stats/rh.aparc.a2009s.txt') ;

dat_lh.Properties.VariableNames = varnam;
dat_rh.Properties.VariableNames = varnam;

for ii = 1:height(dat_lh)
    dat_lh.StructName{ii} = [dat_lh.StructName{ii},'_lh'];
    dat_rh.StructName{ii} = [dat_rh.StructName{ii},'_rh'];
end

fs_dat_col = [dat_lh; dat_rh];

%% Plot summary statistics
xtmp = 1:length(fs_dat_org.StructName);
names = fs_dat_org.StructName;

figure; set(gcf,'Position',[0 0 2000 800])

subplot(9,1,1:2); hold on
scatter(xtmp, fs_dat_org.SurfArea, '.b')
scatter(xtmp, fs_dat_tmp.SurfArea, '.r')
scatter(xtmp, fs_dat_col.SurfArea, '.k')
title('Surface Area'); ylabel('mm^2')
set(gca,'xtick',[])

subplot(9,1,3:4); hold on
scatter(xtmp, fs_dat_org.GrayVol, '.b')
scatter(xtmp, fs_dat_tmp.GrayVol, '.r')
scatter(xtmp, fs_dat_col.GrayVol, '.k')
title('Gray Matter Volume'); ylabel('mm^3')
set(gca,'xtick',[])

subplot(9,1,5:6); hold on
scatter(xtmp, fs_dat_org.ThickAvg, '.b')
scatter(xtmp, fs_dat_tmp.ThickAvg, '.r')
scatter(xtmp, fs_dat_col.ThickAvg, '.k')
title('Average Thickness'); ylabel('mm')
set(gca,'xtick',[])

subplot(9,1,7:8); hold on
scatter(xtmp, fs_dat_org.MeanCurv, '.b')
scatter(xtmp, fs_dat_tmp.MeanCurv, '.r')
scatter(xtmp, fs_dat_col.MeanCurv, '.k')
title('Mean Curvature','Interpreter','none');  ylabel('mm^-1')
set(gca,'xtick',xtmp,'xticklabel', [], 'TickLength', [0.005, 0])
% set(gca,'xtick',[])

% note that the position is relative to your X/Y axis values
for ii = 1:length(names)
    t = text(ii, 0.05, names{ii}, 'FontSize', 7, 'Interpreter','none');
    set(t,'HorizontalAlignment','right','VerticalAlignment','top','Rotation',45);
end

print(fullfile(out_path, 'fs_summaries.png'), '-dpng')

%% Comparison
addpath('/home/mikkel/reliability_analysis/') %https://github.com/mcvinding/reliability_analysis

%% Surface area
dat_ot = [fs_dat_org.SurfArea'; fs_dat_tmp.SurfArea'];
dat_tt = [fs_dat_col.SurfArea'; fs_dat_tmp.SurfArea'];

a_surfArea_ot = reliability_analysis(dat_ot, 'n2fast');
a_surfArea_tt = reliability_analysis(dat_tt, 'n2fast');

[icca_surfArea_ot, lba, uba] = ICC(dat_ot', 'A-1');
[iccc_surfArea_ot, lbc, ubc] = ICC(dat_ot', 'C-1');

[icca_surfArea_tt, lba, uba] = ICC(dat_tt', 'A-1');
[iccc_surfArea_tt, lbc, ubc] = ICC(dat_tt', 'C-1');


%% Gray matter volume
dat_ot = [fs_dat_org.GrayVol'; fs_dat_tmp.GrayVol'];
dat_tt = [fs_dat_col.GrayVol'; fs_dat_tmp.GrayVol'];

a_grayVol_ot = reliability_analysis(dat_ot, 'n2fast');
a_grayVol_tt = reliability_analysis(dat_tt, 'n2fast');

[icca_grayVol_ot, lba, uba] = ICC(dat_ot', 'A-1');
[iccc_grayVol_ot, lbc, ubc] = ICC(dat_ot', 'C-1');

[icca_grayVol_tt, lba, uba] = ICC(dat_tt', 'A-1');
[iccc_grayVol_tt, lbc, ubc] = ICC(dat_tt', 'C-1');


%% Avererage cortical thickness
dat_ot = [fs_dat_org.ThickAvg'; fs_dat_tmp.ThickAvg'];
dat_tt = [fs_dat_col.ThickAvg'; fs_dat_tmp.ThickAvg'];

a_thickAvg_ot = reliability_analysis(dat_ot, 'n2fast');
a_thickAvg_tt = reliability_analysis(dat_tt, 'n2fast');

[icca_thickAvg_ot, lba, uba] = ICC(dat_ot', 'A-1');
[iccc_thickAvg_ot, lbc, ubc] = ICC(dat_ot', 'C-1');

[icca_thickAvg_tt, lba, uba] = ICC(dat_tt', 'A-1');
[iccc_thickAvg_tt, lbc, ubc] = ICC(dat_tt', 'C-1');


%% Mean curvarture
dat_ot = [fs_dat_org.MeanCurv'; fs_dat_tmp.MeanCurv'];
dat_tt = [fs_dat_col.MeanCurv'; fs_dat_tmp.MeanCurv'];

a_meanCurv_ot = reliability_analysis(dat_ot, 'n2fast');
a_meanCurv_tt = reliability_analysis(dat_tt, 'n2fast');

[icca_meanCurv_ot, lba, uba] = ICC(dat_ot', 'A-1');
[iccc_meanCurv_ot, lbc, ubc] = ICC(dat_ot', 'C-1');

[icca_meanCurv_tt, lba, uba] = ICC(dat_tt', 'A-1');
[iccc_meanCurv_tt, lbc, ubc] = ICC(dat_tt', 'C-1');

%END