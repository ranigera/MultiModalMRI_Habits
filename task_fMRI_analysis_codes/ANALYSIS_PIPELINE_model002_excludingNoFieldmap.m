% * This builds on first running steps 1-12 with ANALYSIS_PIPLINE with model '002'

%% *13. ROI ANALYSIS (the confirmatory analysis on the averaged signal in the putamen)
% ---------------------------------------------------------------------------------
% Run it for the right putamen, left putamen and bilateral putamen, on the last 2 vs first 2 runs
% (lev2 contrast 3, thus zstat3) based on the task vs rest onsets (lev1 contrast 8):
% ROI_analysis_preperations(outputDir, fileOfInterest, lev1CopeNum, region, lev1_model)
ROI_analysis_preperations2('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/noFieldmapParticipants_ROI_analysis/', 'zstat3', 8, 'rPutamen', '002')
ROI_analysis_preperations2('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/noFieldmapParticipants_ROI_analysis/', 'zstat3', 8, 'lPutamen', '002')
ROI_analysis_preperations2('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/noFieldmapParticipants_ROI_analysis/', 'zstat3', 8, 'biateralPutamen', '002')

%% --------------------------------------------------------------------------------------------------
% Test for significance in the ROI analyseis:
ROI_dir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/noFieldmapParticipants_ROI_analysis/';
% *REGISTERED ANALYSIS*
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_bilateralPutamen-avg-zstats_last2-vs-first2-runs_based-on-onsets.csv']); pause; clc
% *REGISTERED ANALYSIS (AMBIGUOUS IF REGISTERED)*
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_rPutamen-avg-zstats_last2-vs-first2-runs_based-on-onsets.csv']); pause; clc
% Exploratory analysis:
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_lPutamen-avg-zstats_last2-vs-first2-runs_based-on-onsets.csv']); pause; clc

%% 14. Create the group level fsf files for the (within) 3day group, between-group and individual differences analyses and the launch files to run them:
% using create_group_lev_fsf_3day_group_analyses2(model_name, analysis_name, lev1CopeNum, region)
% - The individual differences analysis (correlatig with habit index) for the within-3day grouo is embedded in the same analysis. 
% * lev1 contrats 8 is the one for task onset vs rest onset.

create_group_lev_fsf_3day_group_analyses2('002', 'last2_vs_first2_runs', 8, 'whole_brain')
create_group_lev_fsf_3day_group_analyses2('002', 'last2_vs_first2_runs', 8, 'putamen')
create_group_lev_fsf_3day_group_analyses2('002', 'last2_vs_first2_runs', 8, 'caudate_head')
create_group_lev_fsf_3day_group_analyses2('002', 'last2_vs_first2_runs', 8, 'vmPFC')

create_group_lev_fsf_3day_group_analyses2('002', 'linear_trend_across_3_days', 8, 'whole_brain')
create_group_lev_fsf_3day_group_analyses2('002', 'linear_trend_across_3_days', 8, 'putamen')
create_group_lev_fsf_3day_group_analyses2('002', 'linear_trend_across_3_days', 8, 'caudate_head')
create_group_lev_fsf_3day_group_analyses2('002', 'linear_trend_across_3_days', 8, 'vmPFC')

create_group_lev_fsf_3day_group_analyses2('002', 'within_day_effects', 8, 'whole_brain')
create_group_lev_fsf_3day_group_analyses2('002', 'within_day_effects', 8, 'putamen')
create_group_lev_fsf_3day_group_analyses2('002', 'within_day_effects', 8, 'caudate_head')
create_group_lev_fsf_3day_group_analyses2('002', 'within_day_effects', 8, 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% using create_group_lev_fsf_between_group_analysis2(model_name, analysis_name, lev1CopeNum, variance_equality, region)
% * lev1 contrats 9 is the one for valued onset vs devalued onset.

create_group_lev_fsf_between_group_analysis2('002', 'extinction_vs_last_run', 9, 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_between_group_analysis2('002', 'extinction_vs_last_run', 9, 'equal_var_assumed', 'putamen')
create_group_lev_fsf_between_group_analysis2('002', 'extinction_vs_last_run', 9, 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_between_group_analysis2('002', 'extinction_vs_last_run', 9, 'equal_var_assumed', 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% * INDIVIDUAL DIFFERENCES across all subjects (extinction vs last run)
% lev1 contrats 9 is the one for valued onset vs devalued onset.
create_group_lev_fsf_individual_diff_across_all2('002', 'extinction_vs_last_run', 9, 'whole_brain')
create_group_lev_fsf_individual_diff_across_all2('002', 'extinction_vs_last_run', 9, 'putamen')
create_group_lev_fsf_individual_diff_across_all2('002', 'extinction_vs_last_run', 9, 'caudate_head')
create_group_lev_fsf_individual_diff_across_all2('002', 'extinction_vs_last_run', 9, 'vmPFC')

%% 15. Execute the launch files to run group level for the (within) 3day group, between-group and individual differences analyses:
% * Existing group level folders will be deleted and replaced.
% - The individual differences analysis (correlatig with habit index) for the within-3day grouo is embedded in the same analysis. 
%
% using run_group_lev_3day_group_analyses2(model, analysis_name, lev1CopeNum, region)
% * lev1 contrats 8 is the one for task onset vs rest onset.

run_group_lev_3day_group_analyses2('002', 'last2_vs_first2_runs', 8, 'whole_brain')
run_group_lev_3day_group_analyses2('002', 'last2_vs_first2_runs', 8, 'putamen')
run_group_lev_3day_group_analyses2('002', 'last2_vs_first2_runs', 8, 'caudate_head')
run_group_lev_3day_group_analyses2('002', 'last2_vs_first2_runs', 8, 'vmPFC')

run_group_lev_3day_group_analyses2('002', 'linear_trend_across_3_days', 8, 'whole_brain')
run_group_lev_3day_group_analyses2('002', 'linear_trend_across_3_days', 8, 'putamen')
run_group_lev_3day_group_analyses2('002', 'linear_trend_across_3_days', 8, 'caudate_head')
run_group_lev_3day_group_analyses2('002', 'linear_trend_across_3_days', 8, 'vmPFC')

run_group_lev_3day_group_analyses2('002', 'within_day_effects', 8, 'whole_brain')
run_group_lev_3day_group_analyses2('002', 'within_day_effects', 8, 'putamen')
run_group_lev_3day_group_analyses2('002', 'within_day_effects', 8, 'caudate_head')
run_group_lev_3day_group_analyses2('002', 'within_day_effects', 8, 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% using run_group_lev_between_group_analysis2(model, analysis_name, lev1CopeNum, variance_equality, region)
% * lev1 contrats 9 is the one for valued onset vs devalued onset.

run_group_lev_between_group_analysis2('002', 'extinction_vs_last_run', 9, 'equal_var_assumed', 'whole_brain')
run_group_lev_between_group_analysis2('002', 'extinction_vs_last_run', 9, 'equal_var_assumed', 'putamen')
run_group_lev_between_group_analysis2('002', 'extinction_vs_last_run', 9, 'equal_var_assumed', 'caudate_head')
run_group_lev_between_group_analysis2('002', 'extinction_vs_last_run', 9, 'equal_var_assumed', 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% * INDIVIDUAL DIFFERENCES across all subjects (extinction vs last run)
% lev1 contrats 9 is the one for qstatvalued onset vs devalued onset.
run_group_lev_individual_diff_across_all2('002', 'extinction_vs_last_run', 9, 'whole_brain')
run_group_lev_individual_diff_across_all2('002', 'extinction_vs_last_run', 9, 'putamen')
run_group_lev_individual_diff_across_all2('002', 'extinction_vs_last_run', 9, 'caudate_head')
run_group_lev_individual_diff_across_all2('002', 'extinction_vs_last_run', 9, 'vmPFC')



%% --------------------------------------------------------------------------------------------------
%% --------------------------------------------------------------------------------------------------
%% --------------------------------------------------------------------------------------------------
%% Exploratory Analysis of data-inferred subgroups (goal-directed/habitual)
%% --------------------------------------------------------------------------------------------------
%% --------------------------------------------------------------------------------------------------
%% --------------------------------------------------------------------------------------------------

%% 16. Compare subgroups of (habitiual vs goal-directed) using the with-group analyses in the 3-day group:

create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'putamen')
create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'vmPFC')

create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'linear_trend_across_3_days', 8,  'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'putamen')
create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'vmPFC')

create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'within_day_effects', 8, 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'within_day_effects', 8, 'equal_var_assumed', 'putamen')
create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'within_day_effects', 8, 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'within_day_effects', 8, 'equal_var_assumed', 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% Now test extinction vs.last run within each group using the subgroups:
% * lev1 contrats 9 is the one for valued onset vs devalued onset.
create_group_lev_fsf_groups_SUB_GROUPS_analyses('002', 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_groups_SUB_GROUPS_analyses('002', 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'putamen')
create_group_lev_fsf_groups_SUB_GROUPS_analyses('002', 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_groups_SUB_GROUPS_analyses('002', 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'vmPFC')

create_group_lev_fsf_groups_SUB_GROUPS_analyses('002', 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_groups_SUB_GROUPS_analyses('002', 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'putamen')
create_group_lev_fsf_groups_SUB_GROUPS_analyses('002', 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_groups_SUB_GROUPS_analyses('002', 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'vmPFC')

% ---------------------------------------------------------------------------------------------------------------------------------------------
%% 17. Execute the launch files:
% Compare subgroups of (habitiual vs goal-directed) using the with-group analyses in the 3-day group:

run_group_lev_3day_SUBGROUPS_analyses('002', 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'whole_brain')
run_group_lev_3day_SUBGROUPS_analyses('002', 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'putamen')
run_group_lev_3day_SUBGROUPS_analyses('002', 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'caudate_head')
run_group_lev_3day_SUBGROUPS_analyses('002', 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'vmPFC')

run_group_lev_3day_SUBGROUPS_analyses('002', 'linear_trend_across_3_days', 8,  'equal_var_assumed', 'whole_brain')
run_group_lev_3day_SUBGROUPS_analyses('002', 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'putamen')
run_group_lev_3day_SUBGROUPS_analyses('002', 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'caudate_head')
run_group_lev_3day_SUBGROUPS_analyses('002', 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'vmPFC')

run_group_lev_3day_SUBGROUPS_analyses('002', 'within_day_effects', 8, 'equal_var_assumed', 'whole_brain')
run_group_lev_3day_SUBGROUPS_analyses('002', 'within_day_effects', 8, 'equal_var_assumed', 'putamen')
run_group_lev_3day_SUBGROUPS_analyses('002', 'within_day_effects', 8, 'equal_var_assumed', 'caudate_head')
run_group_lev_3day_SUBGROUPS_analyses('002', 'within_day_effects', 8, 'equal_var_assumed', 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% Now test extinction vs.last run within each group using the subgroups:
run_group_lev_groups_SUB_GROUPS_analysis('002', 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'whole_brain')
run_group_lev_groups_SUB_GROUPS_analysis('002', 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'putamen')
run_group_lev_groups_SUB_GROUPS_analysis('002', 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'caudate_head')
run_group_lev_groups_SUB_GROUPS_analysis('002', 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'vmPFC')

run_group_lev_groups_SUB_GROUPS_analysis('002', 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'whole_brain')
run_group_lev_groups_SUB_GROUPS_analysis('002', 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'putamen')
run_group_lev_groups_SUB_GROUPS_analysis('002', 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'caudate_head')
run_group_lev_groups_SUB_GROUPS_analysis('002', 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'vmPFC')
