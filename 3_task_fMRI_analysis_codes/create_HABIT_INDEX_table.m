function [behav_dataALL, behav_dataLONG, behav_dataSHORT ]= create_HABIT_INDEX_table()

%% PARAMETERS
% ----------------------------------------------------------------
behav_data_path = '/export2/DATA/HIS/HIS_server/analysis/behavior_analysis_output/my_databases/txt_data/';
behav_data_file_path = '/export2/DATA/HIS/HIS_server/analysis/behavior_analysis_output/my_databases/txt_data/presses_HIS_behavior.csv';

% get the relevant BEHAVIORAL DATA:
behav_data=readtable(behav_data_file_path);
behav_data=behav_data(strcmp(behav_data.VALUE, 'valued'),:); % just to get one line per subject
behav_data(:,2:end-1) = [];

%% TABLE FOR ALL SUBJECTS TOGETHER:
behav_dataALL = behav_data;
% mean_centering:
behav_dataALL.habit_index_mean_centered = behav_dataALL.habit_index - mean(behav_dataALL.habit_index);
behav_dataALL.Properties.VariableNames{1}='subID';
writetable(behav_dataALL, fullfile(behav_data_path, 'habitIndex_ALL.csv'))

%% TABLE FOR LONG TRAINING SUBJECTS:
behav_dataLONG = behav_data(behav_data.ID>200,:);
% mean_centering:
behav_dataLONG.habit_index_mean_centered = behav_dataLONG.habit_index - mean(behav_dataLONG.habit_index);
behav_dataLONG.Properties.VariableNames{1}='subID';
writetable(behav_dataLONG, fullfile(behav_data_path, 'habitIndex_LONG.csv'))

%% TABLE FOR SHORT TRAINING SUBJECTS:
behav_dataSHORT = behav_data(behav_data.ID<200,:);
% mean_centering:
behav_dataSHORT.habit_index_mean_centered = behav_dataSHORT.habit_index - mean(behav_dataSHORT.habit_index);
behav_dataSHORT.Properties.VariableNames{1}='subID';
writetable(behav_dataSHORT, fullfile(behav_data_path, 'habitIndex_SHORT.csv'))

fprintf('** CREATED new habit index file **\n')

quit
end
