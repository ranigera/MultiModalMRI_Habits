%% *13. ROI ANALYSIS (the confirmatory analysis on the averaged signal in the putamen)
% ---------------------------------------------------------------------------------

sphere = 'Tric';
% Run it for the right putamen, left putamen and bilateral putamen, on the last 2 vs first 2 runs
% (lev2 contrast 3, thus zstat3) based on the task vs rest onsets (lev1 contrast 8):
% ROI_analysis_preperations(outputDir, fileOfInterest, lev1CopeNum, region)
ROI_analysis_preperations_sphere('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 8, 'rPutamen', '002',sphere)
ROI_analysis_preperations_sphere('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 8, 'lPutamen', '002',sphere)
ROI_analysis_preperations_sphere('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 8, 'biateralPutamen', '002',sphere)

%% --------------------------------------------------------------------------------------------------
sphere = 'Tric';
% Test for significance in the ROI analyseis:
ROI_dir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/';
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_rPutamen-avg-zstats_last2-vs-first2-runs_based-on-onsets_sphere-' sphere '.csv']); pause; clc
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_bilateralPutamen-avg-zstats_last2-vs-first2-runs_based-on-onsets_sphere-' sphere '.csv']); pause; clc
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_lPutamen-avg-zstats_last2-vs-first2-runs_based-on-onsets_sphere-' sphere '.csv']); pause; clc

%% --------------------------------------------------------------------------------------------------

%% *13. ROI ANALYSIS - now on the whole blocks:
% ---------------------------------------------------------------------------------

sphere = 'Tric';
% Run it for the right putamen, left putamen and bilateral putamen, on the last 2 vs first 2 runs
% (lev2 contrast 3, thus zstat3) based on the task vs rest onsets (lev1 contrast 8):
% ROI_analysis_preperations(outputDir, fileOfInterest, lev1CopeNum, region)
ROI_analysis_preperations_sphere('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 8, 'rPutamen', '003',sphere)
ROI_analysis_preperations_sphere('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 8, 'lPutamen', '003',sphere)
ROI_analysis_preperations_sphere('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 8, 'biateralPutamen', '003',sphere)

%% --------------------------------------------------------------------------------------------------
sphere = 'Tric';
% Test for significance in the ROI analyseis:
ROI_dir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/';
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_rPutamen-avg-zstats_last2-vs-first2-runs_based-on-whole-blocks_sphere-' sphere '.csv']); pause; clc
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_bilateralPutamen-avg-zstats_last2-vs-first2-runs_based-on-whole-blocks_sphere-' sphere '.csv']); pause; clc
system(['Rscript --vanilla ROI_ttest.R ' ROI_dir 'ROI_analysis_lPutamen-avg-zstats_last2-vs-first2-runs_based-on-whole-blocks_sphere-' sphere '.csv']); pause; clc

%% --------------------------------------------------------------------------------------------------

%%
function ROI_analysis_preperations_sphere(outputDir, fileOfInterest, lev1CopeNum, region, lev1_model, sphere)
% ROI_analysis_preperations(outputDir, fileOfInterest, lev1CopeNum, region)
% e.g., ROI_analysis_preperations('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 11, 'rPutamen')
%
% The process is based on the following two lines of codes:
% 1. fslmerge -t allZstats.nii.gz `ls zstat* | sort -V`
% * Creates a 4d volume where each volume is the second-level zstat (or another measure) of one subject.
% 2. fslmeants -i allZstats.nii.gz -m PCG.nii.gz -o averages.txt
% * extracts the average of data in masked area.

%% Define the variables according to inputs:
secondLevFolders = ['/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/sub-*/lev2_models/model' lev1_model '/sub-*_last2_vs_first2_runs.gfeat/cope' num2str(lev1CopeNum) '.feat/stats'];
switch lev1CopeNum
    case 11
        onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
    case 17
        onsetsOrWholeBlocks = 'whole-blocks'; %- (task vs rest)
    % for model 002 and 003:
    case 8
        switch lev1_model
            case '002'
                onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
            case '003'
                onsetsOrWholeBlocks = 'whole-blocks'; % (task vs rest onsetes)
        end
end
switch region
    case 'rPutamen'
        outputFile = ['ROI-rPutamen_all-subjects-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '_sphere-' sphere '.nii.gz'];
        maskFile = ['/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/sphere_post_putamen/PutamenR_' sphere '_sphere_bin.nii.gz'];
        csvFile = ['ROI_analysis_rPutamen-avg-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '_sphere-' sphere '.csv'];
    case 'lPutamen'
        outputFile = ['ROI-lPutamen_all-subjects-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '_sphere-' sphere '.nii.gz'];
        maskFile = ['/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/sphere_post_putamen/PutamenL_' sphere '_sphere_bin.nii.gz'];
        csvFile = ['ROI_analysis_lPutamen-avg-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '_sphere-' sphere '.csv'];
    case 'biateralPutamen'
        outputFile = ['ROI-bilateralPutamen_all-subjects-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '_sphere-' sphere '.nii.gz'];
        maskFile = ['/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/sphere_post_putamen/Putamen_bilateral_' sphere '_sphere_bin.nii.gz'];
        csvFile = ['ROI_analysis_bilateralPutamen-avg-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '_sphere-' sphere '.csv'];
end

%% perform the operations
% 1.
disp('** Creates a 4d volume where each volume is the second-level zstat (or another measure) of one subject')
command = ['fslmerge -t ' fullfile(outputDir, outputFile) ' `ls ' fullfile(secondLevFolders,fileOfInterest) '* | sort -V`'];
% -t = across the time dimension. -V = to order the numbers.
disp(['-- Execute: ' command])
system(command)

% 2.
disp('** Extract average signal/statistic from the mask')
command = ['fslmeants -i ' fullfile(outputDir,outputFile) ' -m ' maskFile ' -o ' fullfile(outputDir, csvFile)];
% -i = input. -m = mask. -o = outputtextfile.
disp(['-- Execute: ' command])
system(command)

% 3. make a seperated list of the subject number and its average zstat in
% the ROI:
[~, list_of_subjects_zstat] = system(['ls ' fullfile(secondLevFolders,fileOfInterest) '* | sort -V']);
list_of_subjects_zstat = strsplit(list_of_subjects_zstat, newline); list_of_subjects_zstat = list_of_subjects_zstat(1:end-1)

end






