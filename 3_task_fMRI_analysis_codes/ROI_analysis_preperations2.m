function ROI_analysis_preperations2(outputDir, fileOfInterest, lev1CopeNum, region, lev1_model)
% ROI_analysis_preperations(outputDir, fileOfInterest, lev1CopeNum, region)
% e.g., ROI_analysis_preperations('/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/ROI_analysis/', 'zstat3', 11, 'rPutamen')
%
% The process is based on the following two lines of codes:
% 1. fslmerge -t allZstats.nii.gz `ls zstat* | sort -V`
% * Creates a 4d volume where each volume is the second-level zstat (or another measure) of one subject.
% 2. fslmeants -i allZstats.nii.gz -m PCG.nii.gz -o averages.txt
% * extracts the average of data in masked area.

%% Define the variables according to inputs:
subjectsToExclude = [101 204 205 241];

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
        outputFile = ['ROI-rPutamen_all-subjects-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '.nii.gz'];
        maskFile = '/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/AAL/aal_fsl_spm12_label_Putamen_R_res-adapted_bin_final-mask.nii.gz';
        csvFile = ['ROI_analysis_rPutamen-avg-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '.csv'];
    case 'lPutamen'
        outputFile = ['ROI-lPutamen_all-subjects-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '.nii.gz'];
        maskFile = '/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/AAL/aal_fsl_spm12_label_Putamen_L_res-adapted_bin_final-mask.nii.gz';
        csvFile = ['ROI_analysis_lPutamen-avg-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '.csv'];
    case 'biateralPutamen'
        outputFile = ['ROI-bilateralPutamen_all-subjects-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '.nii.gz'];
        maskFile = '/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/AAL/aal_fsl_spm12_Putamen_bilateral_res-adapted_bin_final-mask.nii.gz';
        csvFile = ['ROI_analysis_bilateralPutamen-avg-zstats_last2-vs-first2-runs_based-on-' onsetsOrWholeBlocks '.csv'];
end

%% perform the operations
% 1.
disp('** Creates a 4d volume where each volume is the second-level zstat (or another measure) of one subject')

allFiles=dir(['/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/sub-*/lev2_models/model' lev1_model '/sub-*_last2_vs_first2_runs.gfeat/cope' num2str(lev1CopeNum) '.feat/stats/' fileOfInterest '*']);
folders = {allFiles.folder};
for sub=subjectsToExclude
    folders = folders(cellfun(@(x) ~any(strfind(x,num2str(sub))), folders));
end
files = cellfun(@(x) [x filesep 'zstat3.nii.gz '], folders, 'UniformOutput', false);
files = strjoin(files,' ');

command = ['fslmerge -t ' fullfile(outputDir, outputFile) ' ' files];
% -t = across the time dimension. -V = to order the numbers.
disp(['-- Execute: ' command])
system(command)

% 2.
disp('** Extract average signal/statistic from the mask')
command = ['fslmeants -i ' fullfile(outputDir,outputFile) ' -m ' maskFile ' -o ' fullfile(outputDir, csvFile)];
% -i = input. -m = mask. -o = outputtextfile.
disp(['-- Execute: ' command])
system(command)


end






