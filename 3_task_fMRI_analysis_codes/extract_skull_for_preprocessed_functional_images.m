function extract_skull_for_preprocessed_functional_images()
% --------------------------------------------
% Written by Rani Gera, January 2020
% --------------------------------------------
% This function creates brain images(skull stripped) from the preproc and
% brainmask images that are the output of fmriprep (version 1.3.0.post2).
% It uses fsl's fslmaths to multiply the preprocessed bold image with the
% mask image.
% Change parameters to fit if necessary.
% If there is an error with the execution of the command for a file the
% user will be asked if to continue.
% If there are no sessions change areSessions to 0 (*not tested yet*).

% Parameters:
% ----------------------------------------------------------------------------------------
participantsListFile = '/export2/DATA/HIS/HIS_server/BIDS/participants.tsv';
fmriPrepOutputPath   = '/export2/DATA/HIS/HIS_server/BIDS/derivatives/fmriprep/';
OutputPath           = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/'; % The relevant derivative folder
tasks = {'training', 'extinction', 'reacquisition'};
areSessions = 1;
rewriteExistingFiles = 0;
% ----------------------------------------------------------------------------------------
% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);
% if running you can check in the terminal 'echo $FSLDIR' to find the relevant directory. Typically it will be: 
%setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
%setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
%setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin']);
% ----------------------------------------------------------------------------------------

% create subject list:
subList = tdfread(participantsListFile);

% iterate participants:
for i = 1:size(subList.participant_id,1)
    % create session list for the subject:
    if areSessions
        sessions = dir(fullfile(fmriPrepOutputPath, subList.participant_id(i,:),'ses-*'));
        sessions = {sessions.name};
    else
        sessions = {''};
    end
    % iterate sessions:
    for ses = sessions
        % make full paths:
        sub_ses_fmriPrepOutputPath = fullfile(fmriPrepOutputPath,subList.participant_id(i,:),ses{:},'func',filesep);
        sub_ses_OutputPath = fullfile(OutputPath,subList.participant_id(i,:),ses{:}, filesep);
        % create output path if not exists:
        if ~exist(sub_ses_OutputPath, 'dir')
            mkdir(sub_ses_OutputPath)
        end
        % iterate tasks:
        for task = tasks
            preprocFileList = dir([sub_ses_fmriPrepOutputPath '*task-' task{:} '*' '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz']);
            preprocFileList = {preprocFileList.name};
            masksFileList = cellfun(@(x) strrep(x,'preproc_bold','brain_mask'), preprocFileList, 'UniformOutput', false);
            skullStrippedOutputFile = cellfun(@(x) strrep(x,'preproc_bold','preproc_bold_brain'), preprocFileList, 'UniformOutput', false);
            % iterate relevant files (runs)
            for fileInd = 1:length(preprocFileList)
                % check if the skull stripped file is not already exists:
                if ~exist(fullfile(sub_ses_OutputPath, skullStrippedOutputFile{fileInd}), 'file') || rewriteExistingFiles
                    % run the fslmaths to do the skull stripping for the bold
                    fprintf('\n-- skull stripping: %s ...  ', preprocFileList{fileInd})
                    status = system(['fslmaths ' fullfile(sub_ses_fmriPrepOutputPath, preprocFileList{fileInd}) ' -mul ' fullfile(sub_ses_fmriPrepOutputPath, masksFileList{fileInd}) ' ' fullfile(sub_ses_OutputPath, skullStrippedOutputFile{fileInd})]);
                    if status % non-zero means execution failed
                        toContinue = input(['An error occured when running the command on ' preprocFileList{fileInd} '. Continue? y/n[n]:'], 's');
                        if ~strcmp(toContinue, 'y')
                            error('Operation stopped.')
                        end
                    else
                        fprintf('DONE\n')
                    end
                end
            end
        end
    end
end

end
