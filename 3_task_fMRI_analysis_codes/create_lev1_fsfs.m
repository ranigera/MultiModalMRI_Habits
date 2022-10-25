function create_lev1_fsfs(modelName)
%create_Lev1_fsfs(modelName)
% This function cerates the fsfs and launch.txt files ot later run them.
%
% Written by Rani Gera, February 2020, based on Jeannete Mumford python
% script but with some adaptations.
% The function was tested and used for the HIS study: https://osf.io/xrg64.
% It is designed to replace the following place holders inside the fsf
% template:
% {'DATAANALYSISDIR', 'FSLLOCALDIR', 'SUBNUM', 'SESNUM', 'TASKNAME', 'RUNNUM', 'NUMVOLS', 'MODELNAME'}
% with the following variables, respectively:
% {dataAnalysisDir  ,  fslLocalDir ,  subNum ,  sesNum ,  taskName ,  runNum ,  n_vols  ,  modelName}
%
% This function will generate each subject's design.fsf for the first level
% analysis based on a template fsf file, but does not run it.
% modelName - will determine the template fsf (and thereby the design)
% and the location of the files produced by the function.
% Default is '001'.
% Additionally, it will create the a launch file for each subject.
%
% The function was designed to handle both files/tasks that either include or
% does not include runs.
%
% The function also check that the number of volumes is as expected and
% throw an error if it isn't.
%
% Change prameters in the PARAMETERS section to adjust it.


%% PARAMETERS
% ----------------------------------------------------------------
studydir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data'; % The data folder (containing the relevant bolds etc.)
fsfdir   = '/export2/DATA/HIS/HIS_server/codes/fsfs/lev1'; % The directory where it puts all the fsf files
launchdir   = '/export2/DATA/HIS/HIS_server/codes/launchfiles'; % The directory where it puts all the launch files

% rewrite existing fsfs
rewrite_fsfs = 0;
rewrite_launchfiles = 0;

% These will be used for replacements inside the fsfs:
dataAnalysisDir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data';
fslLocalDir = '/share/apps';
expected_n_volumes = struct('training', 492, 'extinction', 192, 'reacquisition', 192); % this will also use to text for the correct number of volumes in the relevant bold file.
if nargin < 1
    modelName = '001';
end

% get the template file
fsfTemplateFile = ['/export2/DATA/HIS/HIS_server/codes/fsfs/templates/template_lev1_model' modelName '.fsf'];

%% set FSL environment (to get the relevant dir run 'echo $FSLDIR' from the terminal)

setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is.
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

listOfNewlyFormedLaunchFiles = {};
%% run the procedure

fprintf(['\n** Creating level 1 fsfs for model ' modelName ' **\n'])
% read the fsf template file into a variable
fsfTemplate = fileread(fsfTemplateFile);

% Get all relevant bold files:
boldFiles = dir(fullfile(studydir, 'sub*/ses*/*desc-preproc_bold_brain.nii.gz'));

% delete launch files if rewrite_launchfiles is true
if rewrite_launchfiles
    subjects = unique(cellfun(@(x) x(strfind(x, 'sub-')+4:strfind(x, '_ses')-1), {boldFiles.name}, 'UniformOutput', false))
    for sub = subjects
        launchfile_to_delete = fullfile(launchdir,['first_model' modelName '_sub-' sub{:} '_launch.txt']);
        if exist(launchfile_to_delete, 'file')
            delete(launchfile_to_delete)
        end
    end
end

for i = 1:length(boldFiles) %iterate each file
    % Get all the relevant data from the file (subNum,sesNum,taskName,runNum [where relevant], n_vols):
    boldFile = boldFiles(i).name;
    subNum = boldFile(strfind(boldFile, 'sub-')+4:strfind(boldFile, '_ses')-1);
    sesNum = boldFile(strfind(boldFile, 'ses-')+4:strfind(boldFile, '_task')-1);
    taskNameStartInd = strfind(boldFile, 'task-')+5; underScores = strfind(boldFile, '_');
    underScoreAfterTaskInd = underScores(underScores > taskNameStartInd); taskNameEndInd = underScoreAfterTaskInd(1) - 1;
    taskName = boldFile(taskNameStartInd:taskNameEndInd);
    if contains(boldFile, '_run-')
        runNum = boldFile(strfind(boldFile, 'run-')+4:strfind(boldFile, '_space')-1);
    else
        runNum = '';
    end
    
    % define the designatedd fsf file name:
    if contains(boldFile, '_run-')
        targetFilePath=fullfile(fsfdir, ['design_lev1_model-' modelName '_sub-' subNum '_ses-' sesNum '_task-' taskName '_run-' runNum '.fsf']);
    else
        targetFilePath=fullfile(fsfdir, ['design_lev1_model-' modelName '_sub-' subNum '_ses-' sesNum '_task-' taskName '.fsf']);
    end
    
    % process and create the new fsf file in case it does not exist or rewrite_fsfs is true:
    if ~exist(targetFilePath, 'file') || rewrite_fsfs || rewrite_launchfiles
        fprintf(['-- processing sub: ' subNum ' | ses: ' sesNum ' | task: ' taskName ' | run (when relevant): ' runNum '\n'])
        
        % get the number of volumes (time-points) and verify it is as should be:
        [~, n_vols] = system(['fslnvols ' fullfile(boldFiles(i).folder, boldFile)]); n_vols = n_vols(1:end-1);
        % test for the correct amount for volumes
        if str2num(n_vols) ~= expected_n_volumes.(taskName)
            error(['The file ' boldFile ' do NOT have the EXPECTED number of volumes/time-points'])
        end
        
        if ~exist(targetFilePath, 'file') || rewrite_fsfs
            % create the replacement mapping:
            if contains(boldFile, '_run-')
                replacements = containers.Map({'DATAANALYSISDIR', 'FSLLOCALDIR', 'SUBNUM', 'SESNUM', 'TASKNAME', 'RUNNUM', 'NUMVOLS', 'MODELNAME'},{dataAnalysisDir, fslLocalDir, subNum, sesNum, taskName, runNum, n_vols, modelName});
            else %adjusting for when there are no runs:
                replacements = containers.Map({'DATAANALYSISDIR', 'FSLLOCALDIR', 'SUBNUM', 'SESNUM', 'TASKNAME', '_run-RUNNUM', 'NUMVOLS', 'MODELNAME'},{dataAnalysisDir, fslLocalDir, subNum, sesNum, taskName, runNum, n_vols, modelName});
            end
            
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
        
        launchFilePath = fullfile(launchdir, ['first_model' modelName '_sub-' subNum '_launch.txt']);
        if ~exist(launchFilePath, 'file') || any(strcmp(launchFilePath, listOfNewlyFormedLaunchFiles)) || rewrite_launchfiles
            fid_launch = fopen(launchFilePath, 'a');
            fprintf(fid_launch, ['feat ' targetFilePath '\n']);
            fclose(fid_launch);
            fprintf(['The command: feat ' targetFilePath ' was written to ' launchFilePath '\n'])
            listOfNewlyFormedLaunchFiles{end+1} = launchFilePath; listOfNewlyFormedLaunchFiles = unique(listOfNewlyFormedLaunchFiles);
        end
    end
end

fprintf(['** Creating level 1 fsfs and launch files for model ' modelName ' COMPLETED **\n'])

end
