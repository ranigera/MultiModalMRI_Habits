function create_group_lev_fsf_individual_diff_across_all2(model_name, analysis_name, lev1CopeNum, region)
%create_group_lev_fsf_individual_diff_across_all(model_name, analysis_name, lev1CopeNum, region)
% * based on the template of template_group_lev_3day_group_analyses.fsf
% * and thus it is based on full_analysis_name with some adjustments.
%
% This function creates the fsfs and launch.txt files for later run them.
%
% Written by Rani Gera, March 2020, based on Jeannete Mumford python
% script but with some adaptations.
% The function was tested and used for the HIS study: https://osf.io/xrg64.
% It is designed to replace the following place holders inside the fsf
% template:
% {'DATAANALYSISDIR', 'FSLLOCALDIR', 'MODELNAME', 'ANALYSIS_TYPE_ONSETS_OR_BLOCKS','ANALYSIS_NAME', 'REGION', 'MASK_FILE', 'NVOLS', 'LEV_2_COPE_INFO', 'FEAT_FILES_FROM_SECOND_LEVEL', 'EV1_VALUE_ASSINGMENTS', 'EV2_VALUE_ASSINGMENTS','GROUP_MEMBERSHIP_VALUE_ASSIGNMENT'}
% { dataAnalysisDir ,  fslLocalDir,   model_name,  analysis_type_onsets_or_blocks , analysis_name ,  region ,  mask_file ,  nvols ,  lev_2_cope_info ,  feat_files_from_lev2         ,  ev1_value_assignment  ,  ev2_value_assignment  , group_membership_value_assignment }
% * 'NVOLS' is determined by the number of subjects.
%
% This analysis is ONLY RELEVANT FOR INDIVIDUAL DIFFERENCES BEFORE VS AFTER DEVALUATION WHEN COLLAPSING ALL SUBJECTS.
%
% This function generates each subject's design.fsf for the a specific second level
% analysis (see the name of the function) based on a template fsf file (but it does not run it).
%
% Input variable
% ----------------
% * model_name - will determine the template fsf (alongside with the analysis name)
% and the location of the files produced by the function.
% relevant models:
% '001'
% * analysis_name - The name of the level 2 analysis:
% ralevant analysis names:
% 'extinction_vs_last_run'
% * lev1CopeNum - The level 1 cope relevant number (i.e., the relevant lev1 contrast)
% * region - will determine the mask to be used (if any) and accordingly
% the output folder. options:
% 'whole_brain'
% 'putamen'
% 'caudate_head'
% 'vmPFC'
% Additionally, it will create a launch file for each subject.
%
% Change prameters in the PARAMETERS section to adjust it.


%% PARAMETERS
% ----------------------------------------------------------------
studydir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data'; % The data folder (containing the relevant bolds etc.)
fsfdir   = '/export2/DATA/HIS/HIS_server/codes/fsfs/group'; % The directory where it puts all the fsf files
launchdir   = '/export2/DATA/HIS/HIS_server/codes/launchfiles'; % The directory where it puts all the launch files
behav_data_file_path = '/export2/DATA/HIS/HIS_server/analysis/behavior_analysis_output/my_databases/txt_data/presses_HIS_behavior.csv';

% mask files:

% rewrite existing fsfs
rewrite_fsfs = 1;
rewrite_launchfiles = 1;

% These will be used for replacements inside the fsfs:
dataAnalysisDir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data_noFieldmap';
fslLocalDir = '/share/apps';

% get the template file
fsfTemplateFile = ['/export2/DATA/HIS/HIS_server/codes/fsfs/templates/template_group_lev_3day_group_analyses.fsf'];

subjectsToExclude = [101 204 205 241];
%% Define variables according to the inputs:
switch lev1CopeNum
    case 12
        onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
    case 18
        onsetsOrWholeBlocks = 'whole-blocks'; %- (task vs rest)
        % for model 002 and 003:
    case 8
        switch model_name
            case '002'
                onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
            case '003'
                onsetsOrWholeBlocks = 'whole-blocks'; % (task vs rest onsetes)
        end
    case 9
        switch model_name
            case '002'
                onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
            case '003'
                onsetsOrWholeBlocks = 'whole-blocks'; % (task vs rest onsetes)
        end
end
analysis_type_onsets_or_blocks = [onsetsOrWholeBlocks '_analysis'];

% define the MASK_FILE according to the input 'region'
switch region
    case 'whole_brain'
        mask_file = '';
    case 'putamen'
        mask_file = '/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/Harvard-Oxford/Putamen_final-mask.nii.gz';
    case 'caudate_head'
        mask_file = '/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/Harvard-Oxford/CaudateHead_Y-larger-than-1_final-mask.nii.gz';
    case 'vmPFC'
        mask_file = '/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/Harvard-Oxford/vmPFC_final-mask.nii.gz';
end

launchFilePath = fullfile(launchdir, ['noFieldMapParticipants_group_model' model_name '_individual-differences_across-all_' analysis_name '_based-on-' onsetsOrWholeBlocks '_' region '_launch.txt']);
%% set FSL environment (to get the relevant dir run 'echo $FSLDIR' from the terminal)

setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is.
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

%% run the procedure

fprintf(['\n** Creating group level fsfs for model ' model_name ': individual differences across ALL subjects - ' analysis_name ' based on ' onsetsOrWholeBlocks ' - ' region ' **\n'])
% read the fsf template file into a variable
fsfTemplate = fileread(fsfTemplateFile);

% Get all the level 2 feat folders:
lev2feat_folders = dir(fullfile(studydir, ['sub-*/lev2_models/model' model_name '/*' analysis_name '.gfeat']));
subjects = {};
lev2feat_full_paths = {};
for folderInd = 1:length({lev2feat_folders.name})
    featFolder = lev2feat_folders(folderInd).name;
    subNum = str2double(featFolder(strfind(featFolder,'sub-')+4 : strfind(featFolder,'_')-1));
    if ~any(strcmp(num2str(subNum), subjects))
        if (subNum > 100 && subNum < 200) || (subNum > 200 && subNum < 300)
            if ~ismember(subNum, subjectsToExclude)
                subjects{end+1} = num2str(subNum);
                lev2feat_full_paths{end+1} = [lev2feat_folders(folderInd).folder filesep lev2feat_folders(folderInd).name];
            end
        end
    end
end

% get the relevant BEHAVIORAL DATA:
behav_data=readtable(behav_data_file_path);
behav_data=behav_data(strcmp(behav_data.VALUE, 'valued'),:); % just to get one line per subject
behav_data(:,2:end-1) = [];
behav_data = behav_data(~ismember(behav_data.ID, subjectsToExclude),:);
% mean_centering:
behav_data.habit_index_mean_centered = behav_data.habit_index - mean(behav_data.habit_index);
% check that fmri data and behavioral data have the same subjects:
if ~isequal(behav_data.ID, cellfun(@str2double, subjects)')
    % there is a fix for the case of 276 who's scan during extinction was
    % in AC-PC 0 and thus excluded from this analysis.
    if strcmp(analysis_name, 'extinction_vs_last_run') && behav_data.ID(~ismember(behav_data.ID,cellfun(@str2double, subjects)')) == 276
        behav_data = behav_data(behav_data.ID~=276,:);
    else
        error('the fmri data and the behavioral data don''t have the same subjects')
    end
end

% delete launch files if rewrite_launchfiles is true
if rewrite_launchfiles
    if exist(launchFilePath, 'file')
        delete(launchFilePath)
    end
end

%% Assemble the (yet to be defined) replacements:
% -------------------------------------------------
lev2CopeNum = length(dir([lev2feat_full_paths{1} filesep 'cope' num2str(lev1CopeNum) '.feat/stats/cope*.nii.gz']));
lev_2_cope_info = ['# Number of lower-level copes feeding into higher-level analysis' newline ...
    'set fmri(ncopeinputs) ' num2str(lev2CopeNum) newline newline];
for lev2CopeInd = 1:lev2CopeNum
    lev_2_cope_info = [lev_2_cope_info '# Use lower-level cope ' num2str(lev2CopeInd) ' for higher-level analysis' newline ...
        'set fmri(copeinput.' num2str(lev2CopeInd) ') 1' newline newline];
end
lev_2_cope_info = lev_2_cope_info(1:end-2);

nvols = num2str(length(lev2feat_full_paths));
feat_files_from_lev2 = '';
ev1_value_assignment = '';
ev2_value_assignment = '';
group_membership_value_assignment = '';
for ind = 1:length(lev2feat_full_paths)
    feat_files_from_lev2 = [feat_files_from_lev2 '# 4D AVW data or FEAT directory (' num2str(ind) ')' newline ...
        'set feat_files(' num2str(ind) ') "' lev2feat_full_paths{ind} '/cope' num2str(lev1CopeNum) '.feat"' newline newline];
    ev1_value_assignment = [ev1_value_assignment '# Higher-level EV value for EV 1 and input ' num2str(ind) newline ...
        'set fmri(evg' num2str(ind) '.1) 1.0' newline newline];
    ev2_value_assignment = [ev2_value_assignment '# Higher-level EV value for EV 2 and input ' num2str(ind) newline ...
        'set fmri(evg' num2str(ind) '.2) ' sprintf('%.15f', behav_data.habit_index_mean_centered(ind)) newline newline];
    group_membership_value_assignment = [group_membership_value_assignment '# Group membership for input ' num2str(ind) newline ...
        'set fmri(groupmem.' num2str(ind) ') 1' newline newline];
end
feat_files_from_lev2 = feat_files_from_lev2(1:end-2); % cut the newline characters at the end.
ev1_value_assignment = ev1_value_assignment(1:end-2); % cut the newline characters at the end.
ev2_value_assignment = ev2_value_assignment(1:end-2); % cut the newline characters at the end.
group_membership_value_assignment = group_membership_value_assignment(1:end-2); % cut the newline characters at the end.


%% Create the fsfs and launch files
% -------------------------------------------------
% define the designated fsf file name:
targetFilePath=fullfile(fsfdir, ['noFieldmapParticipants_design_group_model-' model_name '_individual-differences_across-all_' analysis_name '_based-on-' onsetsOrWholeBlocks '_' region '.fsf']);
% process and create the new fsf file in case it does not exist or rewrite_fsfs is true:
if ~exist(targetFilePath, 'file') || rewrite_fsfs || rewrite_launchfiles
    fprintf(['-- processing group analysis: individual differences (across all subjects) - ' analysis_name ' based on ' onsetsOrWholeBlocks ' - ' region '\n'])
    
    if ~exist(targetFilePath, 'file') || rewrite_fsfs
        full_analysis_name = ['individual-differences_across-all_' analysis_name]; % an edit for this version creating the group fsf.
        % create the replacement mapping:
        replacements = containers.Map({'DATAANALYSISDIR', 'FSLLOCALDIR', 'MODELNAME', 'ANALYSIS_TYPE_ONSETS_OR_BLOCKS','ANALYSIS_NAME', 'REGION', 'MASK_FILE', 'NVOLS', 'LEV_2_COPE_INFO', 'FEAT_FILES_FROM_SECOND_LEVEL', 'EV1_VALUE_ASSINGMENTS', 'EV2_VALUE_ASSINGMENTS', 'GROUP_MEMBERSHIP_VALUE_ASSIGNMENT'}, ...
            { dataAnalysisDir ,  fslLocalDir,   model_name,  analysis_type_onsets_or_blocks ,full_analysis_name,region,  mask_file ,  nvols ,  lev_2_cope_info ,  feat_files_from_lev2         ,  ev1_value_assignment  ,  ev2_value_assignment  ,group_membership_value_assignment });
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
    if ~exist(launchFilePath, 'file') || rewrite_launchfiles
        fid_launch = fopen(launchFilePath, 'a');
        fprintf(fid_launch, ['feat ' targetFilePath '\n']);
        fclose(fid_launch);
        fprintf(['The command: feat ' targetFilePath ' was written to ' launchFilePath '\n'])
    end
end

fprintf(['** Creating group level fsfs and launch files for individual differences (across all) "' analysis_name '" in model ' model_name ' based on ' onsetsOrWholeBlocks ' - ' region ' COMPLETED **\n'])

end
