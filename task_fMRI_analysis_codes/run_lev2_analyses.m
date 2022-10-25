function run_lev2_analyses(model, analysis_name, subjects)

% Created by Rani Gera, February 2020, edited on May 2020.
%
% This function will run the launch.txt files that were created by
% create_lev2_fsfs_3day_group_analyses and those created by create_lev2_between_group_analysis.
% Each launch file includes running the feat command of the lev2_fsfs_[analysis_name] fsf
% for one subject.
%
% Arguments:
% ----------------------
% model_name - the name of the (lev1) model
% relevant models:
% '001'
% analysis_name - The name of the level 2 analysis:
% rlevant analysis names:
% 'last2_vs_first2_runs'
% 'linear_trend_across_3_days'
% 'within_day_effects'.
% and the between group analysis:
% 'extinction_vs_last_run'
%
% subjects - is either a vector of subject numbers or the string 'all' to run
% all the subjects.

%% Parameters:
% ------------------------------
launchdir = '/export2/DATA/HIS/HIS_server/codes/launchfiles';
prefix = ['second_model' model '_' analysis_name];

%% input check:
% ------------------------------
if nargin < 3
    error('The function requires one input argument: either a vector of subject numbers or ''all'' to all the subjects')
end

%% runnning the launch.txt files
% ------------------------------
disp('** Sending the requested second level launch files for execution:')
if ischar(subjects) && strcmp(subjects,'all')
    launchFiles = dir(fullfile(launchdir,[prefix '_sub-*_launch.txt']));
    for file = {launchFiles.name}
        command = ['launch -s ' fullfile(launchdir, file{:}) ' -j schonberglab -p 2 -r inf'];
        disp(['-- Execute: ' command])
        system(command)
    end
elseif isnumeric(subjects)
    for sub = subjects
        file = dir(fullfile(launchdir,[prefix '_sub-' num2str(sub) '_launch.txt']));
        file = {file.name};
        command = ['launch -s ' fullfile(launchdir, file{:}) ' -j schonberglab -p 2 -r inf'];
        disp(['-- Execute: ' command])
        system(command)
    end    
end
disp(['** Sending the requested second level launch files of "' analysis_name '" for execution COMPLETED'])

end


