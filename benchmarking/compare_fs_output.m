

varnam = {'StructName' 'NumVert' 'SurfArea' 'GrayVol' 'ThickAvg' 'ThickStd' 'MeanCurv' 'GausCurv' 'FoldInd' 'CurvInd'};

%% Original MRI
dat_lh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/0177/stats/lh.aparc.a2009s.txt') ;
dat_rh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/0177/stats/rh.aparc.a2009s.txt') ;

dat_lh.Properties.VariableNames = varnam;
dat_rh.Properties.VariableNames = varnam;


for ii = 1:height(dat_lh)
    dat_lh.StructName{ii} = [dat_lh.StructName{ii},'_lh'];
    dat_rh.StructName{ii} = [dat_rh.StructName{ii},'_rh'];
end

fs_dat_org = [dat_lh; dat_rh];

%% Warped template
dat_lh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/0177warp/stats/lh.aparc.a2009s.txt') ;
dat_rh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/0177warp/stats/rh.aparc.a2009s.txt') ;

dat_lh.Properties.VariableNames = varnam;
dat_rh.Properties.VariableNames = varnam;

for ii = 1:height(dat_lh)
    dat_lh.StructName{ii} = [dat_lh.StructName{ii},'_lh'];
    dat_rh.StructName{ii} = [dat_rh.StructName{ii},'_rh'];
end

fs_dat_tmp = [dat_lh; dat_rh];

%% Original template
dat_lh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/colin/stats/lh.aparc.a2009s.txt') ;
dat_rh = readtable('/home/mikkel/mri_warpimg/fs_subjects_dir/colin/stats/rh.aparc.a2009s.txt') ;

dat_lh.Properties.VariableNames = varnam;
dat_rh.Properties.VariableNames = varnam;

for ii = 1:height(dat_lh)
    dat_lh.StructName{ii} = [dat_lh.StructName{ii},'_lh'];
    dat_rh.StructName{ii} = [dat_rh.StructName{ii},'_rh'];
end

fs_dat_col = [dat_lh; dat_rh];

%% Plot

figure; 
subplot(2,2,1); hold on
plot(fs_dat_org.SurfArea, '.b-')
plot(fs_dat_tmp.SurfArea, '.r-')
plot(fs_dat_col.SurfArea, '.k-')
title('Surface Area')

subplot(2,2,2); hold on
plot(fs_dat_org.GrayVol, '.b-')
plot(fs_dat_tmp.GrayVol, '.r-')
plot(fs_dat_col.GrayVol, '.k-')
title('Gray Matter Volume')

subplot(2,2,3); hold on
plot(fs_dat_org.ThickAvg, '.b-')
plot(fs_dat_tmp.ThickAvg, '.r-')
plot(fs_dat_col.ThickAvg, '.k-')
title('Average Thickness')

subplot(2,2,4); hold on
plot(fs_dat_org.MeanCurv, '.b-')
plot(fs_dat_tmp.MeanCurv, '.r-')
plot(fs_dat_col.MeanCurv, '.k-')
title('Mean Curvature')

%% Comparison
addpath('/home/mikkel/reliability_analysis/') %https://github.com/mcvinding/reliability_analysis

%% Surface area
dat_ot = [fs_dat_org.SurfArea'; fs_dat_tmp.SurfArea'];
dat_tt = [fs_dat_col.SurfArea'; fs_dat_tmp.SurfArea'];

a_surfArea_ot = reliability_analysis(dat_ot, 'n2fast');
a_surfArea_tt = reliability_analysis(dat_tt, 'n2fast');

[icca_surfArea_ot, lb, ub] = ICC(dat_ot', 'A-1');
[iccc_surfArea_ot, lb, ub] = ICC(dat_ot', 'C-1');

[icca_surfArea_tt, lb, ub] = ICC(dat_tt', 'A-1');
[iccc_surfArea_tt, lb, ub] = ICC(dat_tt', 'C-1');


%% Gray matter volume
dat_ot = [fs_dat_org.GrayVol'; fs_dat_tmp.GrayVol'];
dat_tt = [fs_dat_col.GrayVol'; fs_dat_tmp.GrayVol'];

a_grayVol_ot = reliability_analysis(dat_ot, 'n2fast');
a_grayVol_tt = reliability_analysis(dat_tt, 'n2fast');

[icca_grayVol_ot, lb, ub] = ICC(dat_ot', 'A-1');
[iccc_grayVol_ot, lb, ub] = ICC(dat_ot', 'C-1');

[icca_grayVol_tt, lb, ub] = ICC(dat_tt', 'A-1');
[iccc_grayVol_tt, lb, ub] = ICC(dat_tt', 'C-1');


%% Avererage cortical thickness
dat_ot = [fs_dat_org.ThickAvg'; fs_dat_tmp.ThickAvg'];
dat_tt = [fs_dat_col.ThickAvg'; fs_dat_tmp.ThickAvg'];

a_thickAvg_ot = reliability_analysis(dat_ot, 'n2fast');
a_thickAvg_tt = reliability_analysis(dat_tt, 'n2fast');

[icca_thickAvg_ot, lb, ub] = ICC(dat_ot', 'A-1');
[iccc_thickAvg_ot, lb, ub] = ICC(dat_ot', 'C-1');

[icca_thickAvg_tt, lb, ub] = ICC(dat_tt', 'A-1');
[iccc_thickAvg_tt, lb, ub] = ICC(dat_tt', 'C-1');


%% Mean curvarture
dat_ot = [fs_dat_org.MeanCurv'; fs_dat_tmp.MeanCurv'];
dat_tt = [fs_dat_col.MeanCurv'; fs_dat_tmp.MeanCurv'];

a_meanCurv_ot = reliability_analysis(dat_ot, 'n2fast');
a_meanCurv_tt = reliability_analysis(dat_tt, 'n2fast');

[icca_meanCurv_ot, lb, ub] = ICC(dat_ot', 'A-1');
[iccc_meanCurv_ot, lb, ub] = ICC(dat_ot', 'C-1');

[icca_meanCurv_tt, lb, ub] = ICC(dat_tt', 'A-1');
[iccc_meanCurv_tt, lb, ub] = ICC(dat_tt', 'C-1');



%END