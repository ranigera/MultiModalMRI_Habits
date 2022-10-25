function fixes_for_fsl_post_fMRIprep_after_lev1(overwrite_existing, modelName)
% Created by Rani Gera at February 2020
% Based on Jeannete Mumford instructions in: https://mumfordbrainstats.tumblr.com/post/166054797696/feat-registration-workaround
%
% This function Performs a few steps required to prevent FSL registration 
% when working with data preprocessed fMRIprep. It should be run after
% running the first-level analysis and before running higher level
% analyses.


%% Parameters:
% ------------------
dataAnalysisDir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data';

%% Run the procedure:
% ------------------
fprintf('\n** Performing adaptations in first level feat dirs to prevent registration by FSL:\n')
lev1featdirs = dir(fullfile(dataAnalysisDir, ['sub-*/ses-*/models/model' modelName '/sub-*_ses-*_task-*.feat']));

for featInd = 1:length(lev1featdirs)
    % get full feat path:
    featpath = [lev1featdirs(featInd).folder filesep lev1featdirs(featInd).name filesep];
    fprintf('-- working on %s\n', featpath)
    % delete reg_standard for the feat directory if exists (created when running higher level analysis or use featregapply):
    if exist([featpath 'reg_standard'], 'dir')
        if strcmp(overwrite_existing, 'dont_overwrite_existing')
            fprintf('@ reg_standard exists - continue to next feat directory.\n')
            continue
        else
            rmdir([featpath 'reg_standard'],'s');
        end
    end
    % delete all .mat files in the reg directory
    delete([featpath 'reg/*.mat']);
    % and replace with the identity matrix
    system(['cp $FSLDIR/etc/flirtsch/ident.mat ' featpath 'reg/example_func2standard.mat']);
    % To prevent interpolation, overwrite standard.nii.gz image with the mean_func.nii.gz:
    system(['cp ' featpath 'mean_func.nii.gz ' featpath 'reg/standard.nii.gz']);
end

fprintf('** Adaptation procedure COMPLETED.\n')

% manipulation check after running the level 2 analyses:
% 1) Make sure stats/cope#.nii.gz and reg_standard/stats/cope#/nii.gz are
%    EXACTLY(!) the same.
% 2) Use fslinfo or fslhd to check that data data dimension and pixel size
%    are the same as the mean_func