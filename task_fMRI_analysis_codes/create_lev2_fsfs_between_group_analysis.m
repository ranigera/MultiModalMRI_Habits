function create_lev2_fsfs_between_group_analysis(model_name, analysis_name)
%create_lev2_fsfs_between_group_analysis
% ! NOTE ! : subject 276 had hos ses-1 run-2 excluded due to scanning the
% extinction run NOT in an angle of -30 degrees.
%
% This function cerates the fsfs and launch.txt files to later run them.
%
% Written by Rani Gera, May 2020, based on Jeannete Mumford python
% script but with some adaptations.
% The function was tested and used for the HIS study: https://osf.io/xrg64.
% It is designed to replace the following place holders inside the fsf
% template:
% {'DATAANALYSISDIR', 'FSLLOCALDIR', 'SUBNUM', 'MODELNAME', 'FINALSESSION', 'FINALRUN'}
% with the following variables, respectively:
% {dataAnalysisDir  ,  fslLocalDir ,  subNum ,  modelName ,  finalsession ,  finalrun }
%
% This analysis is RELEVANT FOR THE BETWEEN GROUP ANALYSIS THAT COMPARES THE DIFFERENCE
% BETWEEN extinction and final training run for the contrast of valud vs devalued.
%
% This function generates each subject's design.fsf for the a specific second level
% analysis (but it does not run it).
%
% Input variable
% ----------------
% model_name - will determine the template fsf (alongside with the analysis name)
% and the location of the files produced by the function.
% relevant models:
% '001'
% analysis_name - The name of the level 2 analysis:
% rlevant analysis names:
% 'extinction_vs_last_run'
%
% Additionally, it will create a launch file for each subject.
%
% Change prameters in the PARAMETERS section to adjust it.


%% PARAMETERS
% ----------------------------------------------------------------
studydir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data'; % The data folder (containing the relevant bolds etc.)
fsfdir   = '/export2/DATA/HIS/HIS_server/codes/fsfs/lev2'; % The directory where it puts all the fsf files
launchdir   = '/export2/DATA/HIS/HIS_server/codes/launchfiles'; % The directory where it puts all the launch files

% rewrite existing fsfs
rewrite_fsfs = 0;
rewrite_launchfiles = 0;

% These will be used for replacements inside the fsfs:
dataAnalysisDir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data';
fslLocalDir = '/share/apps';

% get the template file
fsfTemplateFile = ['/export2/DATA/HIS/HIS_server/codes/fsfs/templates/template_lev2_model' model_name '_' analysis_name '.fsf'];

%% set FSL environment (to get the relevant dir run 'echo $FSLDIR' from the terminal)

setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is.
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

listOfNewlyFormedLaunchFiles = {};
%% run the procedure

fprintf(['\n** Creating level 2 fsfs for model ' model_name ', between-group analysis: ' analysis_name ' **\n'])
% read the fsf template file into a variable
fsfTemplate = fileread(fsfTemplateFile);

% Get all the level 1 feat folders:
lev1feat_folders = dir(fullfile(studydir, ['sub-*/ses-*/models/model' model_name '/*.feat']));
subjects = {};
for folderInd = 1:length({lev1feat_folders.name})
    featFolder = lev1feat_folders(folderInd).name;
    subNum = str2double(featFolder(strfind(featFolder,'sub-')+4 : strfind(featFolder,'_ses')-1));
    if ~any(strcmp(num2str(subNum), subjects))
        if (subNum > 200 && subNum < 300 && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-1_task-training_run-01.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-1_task-training_run-02.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-1_task-training_run-03.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-1_task-training_run-04.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-2_task-training_run-01.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-2_task-training_run-02.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-2_task-training_run-03.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-2_task-training_run-04.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-3_task-training_run-01.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-3_task-training_run-02.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-3_task-training_run-03.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-3_task-training_run-04.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-3_task-extinction.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-3_task-reacquisition.feat']))) ||...
            (subNum > 100 && subNum < 200 && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-1_task-training_run-01.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-1_task-training_run-02.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-1_task-extinction.feat'])) && ...
                any(strcmp({lev1feat_folders.name},['sub-' num2str(subNum) '_ses-1_task-reacquisition.feat'])))
            subjects{end+1} = num2str(subNum);
        end
    end
end


% delete launch files if rewrite_launchfiles is true
if rewrite_launchfiles
    for sub = subjects
        launchfile_to_delete = fullfile(launchdir,['second_model' model_name '_' analysis_name '-' sub{:} '_launch.txt']);
        if exist(launchfile_to_delete, 'file')
            delete(launchfile_to_delete)
        end
    end
end

for i = 1:length(subjects) %iterate each file
    subNum = subjects{i};
    
    % assign the correct last run and last session according to group (inferred by subject number):
    if str2double(subNum) > 100 && str2double(subNum) < 200
        finalsession = '1';
        finalrun = '02';
    elseif str2double(subNum) > 200 && str2double(subNum) < 300
        finalsession = '3';
        finalrun = '04';
    end
    
    % define the designated fsf file name:
    targetFilePath=fullfile(fsfdir, ['design_lev2_model-' model_name '_sub-' subNum '_' analysis_name '.fsf']);
    
    % process and create the new fsf file in case it does not exist or rewrite_fsfs is true:
    if ~exist(targetFilePath, 'file') || rewrite_fsfs || rewrite_launchfiles
        fprintf(['-- processing sub: ' subNum '\n'])
        
        if strcmp(subNum, '276')
            if ~strcmpi(input(['\nDo you want to create a regular fsf for sub-276 (whos extinction was scanned not in -30 degrees angle) for the fsf of: ' ['design_lev2_model-' model_name '_sub-' subNum '_' analysis_name '.fsf'] ' (no/yes):'],'s'),'yes')
                continue
            end
        end
        
        if ~exist(targetFilePath, 'file') || rewrite_fsfs
            % create the replacement mapping:
            replacements = containers.Map({'DATAANALYSISDIR', 'FSLLOCALDIR', 'SUBNUM', 'MODELNAME', 'FINALSESSION', 'FINALRUN'}, {dataAnalysisDir, fslLocalDir, subNum, model_name, finalsession, finalrun});
            
            % Do the replacements:
            fsfAdapted = fsfTemplate;
            for placeHolder = keys(replacements)
                fsfAdapted=strrep(fsfAdapted, placeHolder{:}, replacements(placeHolder{:}));
            end
            
            % write the file:
            fid = fopen(targetFilePath,'w');
            fprintf(fid, '%s', fsfAdapted);
            fclose(fid);
            fprintf(['Created fsf file: ' targetFilePath '\n'])
        end
        % it is possible to run the feat command for the now-formed fsf file
        % right from here but it is not the best practice and we will
        % create a launch file and use launcher:
        
        launchFilePath = fullfile(launchdir, ['second_model' model_name '_' analysis_name '_sub-' subNum '_launch.txt']);
        if ~exist(launchFilePath, 'file') || any(strcmp(launchFilePath, listOfNewlyFormedLaunchFiles)) || rewrite_launchfiles
            fid_launch = fopen(launchFilePath, 'a');
            fprintf(fid_launch, ['feat ' targetFilePath '\n']);
            fclose(fid_launch);
            fprintf(['The command: feat ' targetFilePath ' was written to ' launchFilePath '\n'])
            listOfNewlyFormedLaunchFiles{end+1} = launchFilePath; listOfNewlyFormedLaunchFiles = unique(listOfNewlyFormedLaunchFiles);
        end
    end
end

fprintf(['** Creating level 2 fsfs and launch files for between-group analysis: "' analysis_name '" in model ' model_name ' COMPLETED **\n'])

end
