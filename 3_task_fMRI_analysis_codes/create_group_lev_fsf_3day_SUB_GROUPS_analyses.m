function create_group_lev_fsf_3day_SUB_GROUPS_analyses(model_name, analysis_name, lev1CopeNum, variance_equality, region)
% Created using the based on the functions function of the group-lvel
% analysis of the main analysis.
% Examople: create_group_lev_fsf_3day_SUB_GROUPS_analyses('002', 'last2_vs_first2_runs', 8, 'equal_var_assumed', 'whole_brain')

%% PARAMETERS
% ----------------------------------------------------------------
studydir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data'; % The data folder (containing the relevant bolds etc.)
fsfdir   = '/export2/DATA/HIS/HIS_server/codes/fsfs/group'; % The directory where it puts all the fsf files
launchdir   = '/export2/DATA/HIS/HIS_server/codes/launchfiles'; % The directory where it puts all the launch files
behav_SUB_GROUPS_data_file_path = '/export2/DATA/HIS/HIS_server/analysis/behavior_analysis_output/my_databases/txt_data/clustered_subgroups_HIS_May_2022.csv';

% mask files:

% rewrite existing fsfs
rewrite_fsfs = 1;
rewrite_launchfiles = 1;

% These will be used for replacements inside the fsfs:
dataAnalysisDir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data';
fslLocalDir = '/share/apps';

% get the template file
fsfTemplateFile = ['/export2/DATA/HIS/HIS_server/codes/fsfs/templates/template_group_lev_3day_group_analyses_SUBGROUPS.fsf'];

%% Define variables according to the inputs:
switch lev1CopeNum
    case 11
        onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
    case 17
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
    case 'sphere_putamen'
        mask_file = '/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/sphere_post_putamen/Putamen_bilateral_Tric_sphere_bin.nii.gz';
    case 'sphere_putamen_rani'
        mask_file = '/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/sphere_post_putamen/Putamen_bilateral_Rani_sphere_bin.nii.gz';
    case 'sphere_putamen_right'
        mask_file = '/export2/DATA/HIS/HIS_server/fMRI_assistance_files/masks/sphere_post_putamen/PutamenR_Tric_sphere_bin.nii.gz';
end




% launch file full path:
launchFilePath = fullfile(launchdir, ['group_model' model_name '_SubGroups_' analysis_name '_' variance_equality '_based-on-' onsetsOrWholeBlocks '_' region '_launch.txt']);
%% set FSL environment (to get the relevant dir run 'echo $FSLDIR' from the terminal)

setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is.
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

%% run the procedure

fprintf(['\n** Creating group level fsfs for model ' model_name ' SubGroups ' analysis_name ' based on ' onsetsOrWholeBlocks ' - ' variance_equality ' - ' region ' **\n'])
% read the fsf template file into a variable
fsfTemplate = fileread(fsfTemplateFile);

% Change EV titles:
fsfTemplate = strrep(fsfTemplate, 'set fmri(evtitle1) ""','set fmri(evtitle1) "Habitual"');
fsfTemplate = strrep(fsfTemplate, 'set fmri(evtitle2) "habit index"','set fmri(evtitle2) "Goal_directed"');

% Get all the level 2 feat folders:
lev2feat_folders = dir(fullfile(studydir, ['sub-*/lev2_models/model' model_name '/*' analysis_name '.gfeat']));
subjects = {};
lev2feat_full_paths = {};
for folderInd = 1:length({lev2feat_folders.name})
    featFolder = lev2feat_folders(folderInd).name;
    subNum = str2double(featFolder(strfind(featFolder,'sub-')+4 : strfind(featFolder,'_')-1));
    if ~any(strcmp(num2str(subNum), subjects))
        if subNum > 200 && subNum < 300
            subjects{end+1} = num2str(subNum);
            lev2feat_full_paths{end+1} = [lev2feat_folders(folderInd).folder filesep lev2feat_folders(folderInd).name];
        end
    end
end

% get the relevant BEHAVIORAL DATA:
behav_data=readtable(behav_SUB_GROUPS_data_file_path);
%%%behav_data=behav_data(strcmp(behav_data.VALUE, 'valued'),:); % just to get one line per subject
%%%behav_data(:,2:end-1) = [];
behav_data_3day_group = behav_data(behav_data.ID > 200 & behav_data.ID < 300,:);

% Remove folders of subjects that do not appear in the behavor file: 
lev2feat_full_paths = lev2feat_full_paths(ismember(cellfun(@str2double, subjects)', behav_data_3day_group.ID)); % the order of this two lines is important
subjects = subjects(ismember(cellfun(@str2double, subjects)', behav_data_3day_group.ID));

% mean_centering:
behav_data_3day_group.habit_index_mean_centered = behav_data_3day_group.habit_score - mean(behav_data_3day_group.habit_score);
% check that fmri data and behavioral data have the same subjects:
if ~isequal(behav_data_3day_group.ID, cellfun(@str2double, subjects)')
        % there is a fix for the case of 251 and linear_trend_across_3_days
    % (because they he/she should not be included in it due to an excluded
    % run).
    if strcmp(analysis_name, 'linear_trend_across_3_days') && behav_data_3day_group.ID(~ismember(behav_data_3day_group.ID,cellfun(@str2double, subjects)')) == 251
        behav_data_3day_group = behav_data_3day_group(behav_data_3day_group.ID~=251,:);
    else
        error('the fmri data and the behavioral data don''t have the same subjects')
    end
    %disp('DEBUGGING MODE')
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
group_num_options = [1 2];
for ind = 1:length(lev2feat_full_paths)
    feat_files_from_lev2 = [feat_files_from_lev2 '# 4D AVW data or FEAT directory (' num2str(ind) ')' newline ...
        'set feat_files(' num2str(ind) ') "' lev2feat_full_paths{ind} '/cope' num2str(lev1CopeNum) '.feat"' newline newline];
    ev1_value_assignment = [ev1_value_assignment '# Higher-level EV value for EV 1 and input ' num2str(ind) newline ...
        'set fmri(evg' num2str(ind) '.1) ' num2str(strcmp(behav_data_3day_group.Cluster{ind},'Habitual')) newline newline];
    ev2_value_assignment = [ev2_value_assignment '# Higher-level EV value for EV 2 and input ' num2str(ind) newline ...
        'set fmri(evg' num2str(ind) '.2) ' num2str(strcmp(behav_data_3day_group.Cluster{ind},'Goal-directed')) newline newline];
    if strcmp(variance_equality, 'equal_var_assumed')
        group_membership_value_assignment = [group_membership_value_assignment '# Group membership for input ' num2str(ind) newline ...
            'set fmri(groupmem.' num2str(ind) ') 1' newline newline];
    elseif strcmp(variance_equality, 'unequal_var_assumed')
        group_membership_value_assignment = [group_membership_value_assignment '# Group membership for input ' num2str(ind) newline ...
            'set fmri(groupmem.' num2str(ind) ') ' num2str(group_num_options(strcmp(behav_data_3day_group.Cluster{ind},{'Habitual','Goal-directed'}))) newline newline];
    end
end
feat_files_from_lev2 = feat_files_from_lev2(1:end-2); % cut the newline characters at the end.
ev1_value_assignment = ev1_value_assignment(1:end-2); % cut the newline characters at the end.
ev2_value_assignment = ev2_value_assignment(1:end-2); % cut the newline characters at the end.
group_membership_value_assignment = group_membership_value_assignment(1:end-2); % cut the newline characters at the end.


%% Create the fsfs and launch files
% -------------------------------------------------
% define the designated fsf file name:
targetFilePath=fullfile(fsfdir, ['design_group_model-' model_name '_SubGroups_' analysis_name '_' variance_equality '_based-on-' onsetsOrWholeBlocks '_' region '.fsf']);
% process and create the new fsf file in case it does not exist or rewrite_fsfs is true:
if ~exist(targetFilePath, 'file') || rewrite_fsfs || rewrite_launchfiles
    fprintf(['-- processing group analysis: SubGroups - ' analysis_name ' based on ' onsetsOrWholeBlocks ' - ' region '\n'])
    
    if ~exist(targetFilePath, 'file') || rewrite_fsfs
        % create the replacement mapping:
        replacements = containers.Map({'DATAANALYSISDIR', 'FSLLOCALDIR', 'MODELNAME', 'ANALYSIS_TYPE_ONSETS_OR_BLOCKS','ANALYSIS_NAME', 'VARIANCE_EQUALITY', 'REGION', 'MASK_FILE', 'NVOLS', 'LEV_2_COPE_INFO', 'FEAT_FILES_FROM_SECOND_LEVEL', 'EV1_VALUE_ASSINGMENTS', 'EV2_VALUE_ASSINGMENTS', 'GROUP_MEMBERSHIP_VALUE_ASSIGNMENT'}, ...
                                      { dataAnalysisDir ,  fslLocalDir,   model_name,  analysis_type_onsets_or_blocks ,['SubGroups_' analysis_name]  , variance_equality, region ,  mask_file ,  nvols ,  lev_2_cope_info ,  feat_files_from_lev2         ,  ev1_value_assignment  ,  ev2_value_assignment  ,group_membership_value_assignment });

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

fprintf(['** Creating group level fsfs and launch files for "SubGroups ' analysis_name '" in model ' model_name ' based on ' onsetsOrWholeBlocks ' - ' region ' COMPLETED **\n'])

end
