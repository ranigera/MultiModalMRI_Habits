function run_lev1(subjects, model)

% Created by Rani Gera, February 2020.
%
% This function will run the launch.txt files that were created by
% create_lev1_fsfs. Each launch file includes running the feat command of all the level 1 fsfs of one subject.
%
% Arguments:
% subjects - is either a vector of subject numbers or the string 'all' to run
% all the subjects.
% model - default is 001

%% Parameters:
% ------------------------------
launchdir = '/export2/DATA/HIS/HIS_server/codes/launchfiles';
if nargin < 2
    model = '001';
end
prefix = ['first_model' model];

%% input check:
% ------------------------------
if nargin < 1
    error('The function requires one input argument: either a vector of subject numbers or ''all'' to all the subjects')
end

%% runnning the launch.txt files
% ------------------------------
disp('** Sending the requested first level launch files for execution:')
if ischar(subjects) && strcmp(subjects,'all')
    launchFiles = dir(fullfile(launchdir,[prefix '_sub-*_launch.txt']));
    for file = {launchFiles.name}
        command = ['launch -s ' fullfile(launchdir, file{:}) ' -j schonberglab -p 4 -r inf'];
        disp(['-- Execute: ' command])
        system(command)
    end
elseif isnumeric(subjects)
    for sub = subjects
        file = dir(fullfile(launchdir,[prefix '_sub-' num2str(sub) '_launch.txt']));
        file = {file.name};
        command = ['launch -s ' fullfile(launchdir, file{:}) ' -j schonberglab -p 4 -r inf'];
        disp(['-- Execute: ' command])
        system(command)
    end    
end
disp('** Sending the requested first level launch files for execution COMPLETED')

end


