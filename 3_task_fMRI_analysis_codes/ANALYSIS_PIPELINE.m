% Potential models:
% * Model 001 included both the onsets and whole block regressors (but was found to nto be suitable)
% * Model 002 is similar to model 001 but includes only the onsets (whole block regressors are omitted)
% * Model 003 is similar to model 001 but includes only the whole blocks (onsets regressors are omitted)

% If the bash commands to run bash and python scripts do not run make the
% files executable using 'chmod x+ FileName'

%% Define model to run:
modelToRun = '002';

%% FOLLOWING fMRIprep
% -------------------------------------------------------------------------
%% 0. Make sure fMRIprep ran with NO ERRORS for all the subjects:
verify_fMRIprep_output()

%% 1. Extract the skull from the preprocessed (task) fMRI (using fslmath):
extract_skull_for_preprocessed_functional_images()

%% 2. Create motion confounds and do related QA:
create_motion_confounds_files_after_fmriprep_v2_and_related_qa()

%% 3. Create event.tsv files:
create_event_files()

%% 4. Create onset files (based on the evets.tsv files):
system(['./runBIDSto3col_all_subjects.sh ' modelToRun]) % this files use BIDSto3col.sh. * The argument is the model name.

%% 5. Create the first level fsf files (based on a prepared template) and the launch files to run them: 
create_lev1_fsfs(modelToRun)

%% 6. Execute the launch files to run first level:
SUBJECTS = [277];
run_lev1(SUBJECTS, modelToRun) % The argument must be either 'all' ot a vector of subject numbers.

%%
% Use this if there is a problem with running the launch files:
run_lev1_launch_alternative(SUBJECTS, modelToRun) 

%% FOLLOWING FIRST-LEVEL ANALYSIS
% -------------------------------------------------------------------------
%% 7. Create first-level QA html file (with a associated files in a subfolder)
system(['./QA_all_lev1s.py ' modelToRun])
% The registration parts of the QA are irrelevant
% The design and collinearity issues are relevant.

%% 8. Fixes to enable higher level analyses without FSL registration (as it was done by fMRIprep):
fixes_for_fsl_post_fMRIprep_after_lev1('dont_overwrite_existing', modelToRun)

%% 9. Create the seconds level fsf files and the launch files to run them:
% for the (within) 3day group analyses: 
create_lev2_fsfs_3day_group_analyses(modelToRun, 'last2_vs_first2_runs')
create_lev2_fsfs_3day_group_analyses(modelToRun, 'linear_trend_across_3_days')
create_lev2_fsfs_3day_group_analyses(modelToRun, 'within_day_effects')
% for the BETWEEN group analysis: 
create_lev2_fsfs_between_group_analysis(modelToRun, 'extinction_vs_last_run')

%% 10. Execute the launch files to run second level:
SUBJECTS = [281 282]; % The argument must be either 'all' or a vector of subject numbers. Adjust the parts with SUBJECTS(SUBJECTS>200) below if needed.
% for the 3-day within-group analysis:
run_lev2_analyses(modelToRun, 'last2_vs_first2_runs',SUBJECTS(SUBJECTS>200)) 
run_lev2_analyses(modelToRun, 'linear_trend_across_3_days',SUBJECTS(SUBJECTS>200)) 
run_lev2_analyses(modelToRun, 'within_day_effects',SUBJECTS(SUBJECTS>200)) 
% for the BETWEEN group analysis: 
run_lev2_analyses(modelToRun, 'extinction_vs_last_run',SUBJECTS)

%%
%Use this if there is a problem with running the launch files:
% for the 3-day within-group analysis:
run_lev2_analyses_launch_alternative(modelToRun, 'last2_vs_first2_runs',SUBJECTS) 
run_lev2_analyses_launch_alternative(modelToRun, 'linear_trend_across_3_days',SUBJECTS) 
run_lev2_analyses_launch_alternative(modelToRun, 'within_day_effects',SUBJECTS) 
% for the BETWEEN group analysis: 
run_lev2_analyses_launch_alternative(modelToRun, 'extinction_vs_last_run',SUBJECTS) 

%% FOLLOWING SECOND-LEVEL ANALYSIS
% -------------------------------------------------------------------------
%% 11. Create second-level QA html file (with a associated files in a subfolder):
system(['./QA_all_lev2s.py ' modelToRun])
% examine the formed html to make sure there are no parts of the brain with
% missing parts (data) in one of the scans (which prevent those voxels from being analyzed).

%% 12. Create the behavioral indices files (to corelate with the fMRI data):
analysis_behavior_HIS_server; % extract, calculate the indices and arange the data in files.

%% *13. ROI ANALYSIS (the confirmatory analysis on the averaged signal in the putamen)
% ---------------------------------------------------------------------------------
% Run it for the right putamen, left putamen and bilateral putamen, on the last 2 vs first 2 runs
% (lev2 contrast 3, thus zstat3) based on the task vs rest onsets (lev1 contrast 8):
% ROI_analysis_preperations(outputDir, fileOfInterest, lev1CopeNum, region, lev1_model)
ROI_analysis_preperations('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 8, 'rPutamen', modelToRun)
ROI_analysis_preperations('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 8, 'lPutamen', modelToRun)
ROI_analysis_preperations('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 8, 'biateralPutamen', modelToRun)

%% --------------------------------------------------------------------------------------------------
% Test for significance in the ROI analyseis:
ROI_dir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/';
% *REGISTERED ANALYSIS*
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_rPutamen-avg-zstats_last2-vs-first2-runs_based-on-onsets.csv']); pause; clc
% Exploratory analysis:
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_bilateralPutamen-avg-zstats_last2-vs-first2-runs_based-on-onsets.csv']); pause; clc
% Exploratory analysis:
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_lPutamen-avg-zstats_last2-vs-first2-runs_based-on-onsets.csv']); pause; clc

%% 14. Create the group level fsf files for the (within) 3day group, between-group and individual differences analyses and the launch files to run them:
% using create_group_lev_fsf_3day_group_analyses(model_name, analysis_name, lev1CopeNum, region)
% - The individual differences analysis (correlatig with habit index) for the within-3day group is embedded in the same analysis. 
% * lev1 contrats 8 is the one for task onset vs rest onset.

create_group_lev_fsf_3day_group_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'whole_brain')
create_group_lev_fsf_3day_group_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'putamen')
create_group_lev_fsf_3day_group_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'caudate_head')
create_group_lev_fsf_3day_group_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'vmPFC')

create_group_lev_fsf_3day_group_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'whole_brain')
create_group_lev_fsf_3day_group_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'putamen')
create_group_lev_fsf_3day_group_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'caudate_head')
create_group_lev_fsf_3day_group_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'vmPFC')

create_group_lev_fsf_3day_group_analyses(modelToRun, 'within_day_effects', 8, 'whole_brain')
create_group_lev_fsf_3day_group_analyses(modelToRun, 'within_day_effects', 8, 'putamen')
create_group_lev_fsf_3day_group_analyses(modelToRun, 'within_day_effects', 8, 'caudate_head')
create_group_lev_fsf_3day_group_analyses(modelToRun, 'within_day_effects', 8, 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% using create_group_lev_fsf_between_group_analysis(model_name, analysis_name, lev1CopeNum, variance_equality, region)
% * lev1 contrats 9 is the one for valued onset vs devalued onset.

create_group_lev_fsf_between_group_analysis(modelToRun, 'extinction_vs_last_run', 9, 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_between_group_analysis(modelToRun, 'extinction_vs_last_run', 9, 'equal_var_assumed', 'putamen')
create_group_lev_fsf_between_group_analysis(modelToRun, 'extinction_vs_last_run', 9, 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_between_group_analysis(modelToRun, 'extinction_vs_last_run', 9, 'equal_var_assumed', 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% * INDIVIDUAL DIFFERENCES across all subjects (extinction vs last run)
% lev1 contrats 9 is the one for valued onset vs devalued onset.
create_group_lev_fsf_individual_diff_across_all(modelToRun, 'extinction_vs_last_run', 9, 'whole_brain')
create_group_lev_fsf_individual_diff_across_all(modelToRun, 'extinction_vs_last_run', 9, 'putamen')
create_group_lev_fsf_individual_diff_across_all(modelToRun, 'extinction_vs_last_run', 9, 'caudate_head')
create_group_lev_fsf_individual_diff_across_all(modelToRun, 'extinction_vs_last_run', 9, 'vmPFC')

%% 15. Execute the launch files to run group level for the (within) 3day group, between-group and individual differences analyses:
% * Existing group level folders will be deleted and replaced.
% - The individual differences analysis (correlatig with habit index) for the within-3day grouo is embedded in the same analysis. 
%
% using run_group_lev_3day_group_analyses(model, analysis_name, lev1CopeNum, region)
% * lev1 contrats 8 is the one for task onset vs rest onset.

run_group_lev_3day_group_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'whole_brain')
run_group_lev_3day_group_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'putamen')
run_group_lev_3day_group_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'caudate_head')
run_group_lev_3day_group_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'vmPFC')

run_group_lev_3day_group_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'whole_brain')
run_group_lev_3day_group_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'putamen')
run_group_lev_3day_group_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'caudate_head')
run_group_lev_3day_group_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'vmPFC')

run_group_lev_3day_group_analyses(modelToRun, 'within_day_effects', 8, 'whole_brain')
run_group_lev_3day_group_analyses(modelToRun, 'within_day_effects', 8, 'putamen')
run_group_lev_3day_group_analyses(modelToRun, 'within_day_effects', 8, 'caudate_head')
run_group_lev_3day_group_analyses(modelToRun, 'within_day_effects', 8, 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% using run_group_lev_between_group_analysis(model, analysis_name, lev1CopeNum, variance_equality, region)
% * lev1 contrats 9 is the one for valued onset vs devalued onset.

run_group_lev_between_group_analysis(modelToRun, 'extinction_vs_last_run', 9, 'equal_var_assumed', 'whole_brain')
run_group_lev_between_group_analysis(modelToRun, 'extinction_vs_last_run', 9, 'equal_var_assumed', 'putamen')
run_group_lev_between_group_analysis(modelToRun, 'extinction_vs_last_run', 9, 'equal_var_assumed', 'caudate_head')
run_group_lev_between_group_analysis(modelToRun, 'extinction_vs_last_run', 9, 'equal_var_assumed', 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% * INDIVIDUAL DIFFERENCES across all subjects (extinction vs last run)
% lev1 contrats 9 is the one for qstatvalued onset vs devalued onset.
run_group_lev_individual_diff_across_all(modelToRun, 'extinction_vs_last_run', 9, 'whole_brain')
run_group_lev_individual_diff_across_all(modelToRun, 'extinction_vs_last_run', 9, 'putamen')
run_group_lev_individual_diff_across_all(modelToRun, 'extinction_vs_last_run', 9, 'caudate_head')
run_group_lev_individual_diff_across_all(modelToRun, 'extinction_vs_last_run', 9, 'vmPFC')


%% --------------------------------------------------------------------------------------------------
%% --------------------------------------------------------------------------------------------------
%% --------------------------------------------------------------------------------------------------
%% Exploratory Analysis of data-inferred subgroups (goal-directed/habitual)
%% --------------------------------------------------------------------------------------------------
%% --------------------------------------------------------------------------------------------------
%% --------------------------------------------------------------------------------------------------

%% 16. Compare subgroups of (habitiual vs goal-directed) using the with-group analyses in the 3-day group:

create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'putamen')
create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'vmPFC')

create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'linear_trend_across_3_days', 8,  'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'putamen')
create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'vmPFC')

create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'within_day_effects', 8, 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'within_day_effects', 8, 'equal_var_assumed', 'putamen')
create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'within_day_effects', 8, 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_3day_SUB_GROUPS_analyses(modelToRun, 'within_day_effects', 8, 'equal_var_assumed', 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% Now test extinction vs.last run within each group using the subgroups:
% * lev1 contrats 9 is the one for valued onset vs devalued onset.

create_group_lev_fsf_groups_SUB_GROUPS_analyses(modelToRun, 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_groups_SUB_GROUPS_analyses(modelToRun, 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'putamen')
create_group_lev_fsf_groups_SUB_GROUPS_analyses(modelToRun, 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_groups_SUB_GROUPS_analyses(modelToRun, 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'vmPFC')

create_group_lev_fsf_groups_SUB_GROUPS_analyses(modelToRun, 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'whole_brain')
create_group_lev_fsf_groups_SUB_GROUPS_analyses(modelToRun, 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'putamen')
create_group_lev_fsf_groups_SUB_GROUPS_analyses(modelToRun, 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'caudate_head')
create_group_lev_fsf_groups_SUB_GROUPS_analyses(modelToRun, 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'vmPFC')

% ---------------------------------------------------------------------------------------------------------------------------------------------
%% 17. Execute the launch files:
% Compare subgroups of (habitiual vs goal-directed) using the with-group analyses in the 3-day group:

run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'whole_brain')
run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'putamen')
run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'caudate_head')
run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'vmPFC')

run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'linear_trend_across_3_days', 8,  'equal_var_assumed', 'whole_brain')
run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'putamen')
run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'caudate_head')
run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'linear_trend_across_3_days', 8, 'equal_var_assumed', 'vmPFC')

run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'within_day_effects', 8, 'equal_var_assumed', 'whole_brain')
run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'within_day_effects', 8, 'equal_var_assumed', 'putamen')
run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'within_day_effects', 8, 'equal_var_assumed', 'caudate_head')
run_group_lev_3day_SUBGROUPS_analyses(modelToRun, 'within_day_effects', 8, 'equal_var_assumed', 'vmPFC')

%% --------------------------------------------------------------------------------------------------
% Now test extinction vs.last run within each group using the subgroups:
run_group_lev_groups_SUB_GROUPS_analysis(modelToRun, 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'whole_brain')
run_group_lev_groups_SUB_GROUPS_analysis(modelToRun, 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'putamen')
run_group_lev_groups_SUB_GROUPS_analysis(modelToRun, 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'caudate_head')
run_group_lev_groups_SUB_GROUPS_analysis(modelToRun, 'extinction_vs_last_run', 9, 'short', 'equal_var_assumed', 'vmPFC')

run_group_lev_groups_SUB_GROUPS_analysis(modelToRun, 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'whole_brain')
run_group_lev_groups_SUB_GROUPS_analysis(modelToRun, 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'putamen')
run_group_lev_groups_SUB_GROUPS_analysis(modelToRun, 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'caudate_head')
run_group_lev_groups_SUB_GROUPS_analysis(modelToRun, 'extinction_vs_last_run', 9, 'long', 'equal_var_assumed', 'vmPFC')
