function run_group_lev_3day_SUBGROUPS_analyses(model, analysis_name, lev1CopeNum, variance_equality, region)
%run_lev2_3day_group_analyses(model, analysis_name, region)
% Created by Rani Gera, February 2020.
%
% This function will run the launch.txt files that were created by
% create_group_lev_fsf_3day_group_analyses. Each launch file includes
% running the feat command of the group_lev_fsfs_[analysis_name]_[region in the brain] fsf.
%
% Arguments:
% ----------------------
% * smodel_name - the name of the (lev1) model
% relevant models:
% '001'
% * analysis_name - The name of the level 2 analysis:
% rlevant analysis names:
% 'last2_vs_first2_runs'
% 'linear_trend_across_3_days'
% 'within_day_effects'.
% * region - the region in the brain for in the analysis:
% options: 'whole_brain', 'putamen, 'caudate_head', 'vmPFC's.

%% Parameters:
% ------------------------------
% Define variables according to the inputs:
switch lev1CopeNum
    case 11
        onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
    case 17
        onsetsOrWholeBlocks = 'whole-blocks'; %- (task vs rest)
    % for model 002 and 003:
    case 8
        switch model
            case '002'
                onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
            case '003'
                onsetsOrWholeBlocks = 'whole-blocks'; % (task vs rest onsetes)
        end
    case 9
        switch model
            case '002'
                onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
            case '003'
                onsetsOrWholeBlocks = 'whole-blocks'; % (task vs rest onsetes)
        end
end

launchdir = '/export2/DATA/HIS/HIS_server/codes/launchfiles';
file = ['group_model' model '_SubGroups_' analysis_name '_' variance_equality '_based-on-' onsetsOrWholeBlocks '_' region '_launch.txt'];

%% input check:
% ------------------------------
if nargin < 5
    error('The function requires 5 input arguments: model, analysis_name, region.')
end

%% runnning the launch.txt files
% ------------------------------
disp('** Sending the requested group level launch files for execution:')
% Check if gfeat output folder already exists:
fsfFile = char(extractBetween(fileread(fullfile(launchdir, file)), ' ', newline));
targetOutputFolder = [char(extractBetween(fileread(fsfFile), 'set fmri(outputdir) "', '"')) '.gfeat'];
% Delete gfeat if exists:
if exist(targetOutputFolder, 'dir')
    disp('-- Output directory (gfeat of the group analysis) exists, DELETING existing directory.')
    deleted = rmdir(targetOutputFolder, 's');
    if deleted
        disp('-- Existing Output directory was DELETED.')
    else
        error('-- Existing Output directory was NOT DELETED succesfully, Operation stopped.')
    end
end
% Execute launch file:
command = ['launch -s ' fullfile(launchdir, file) ' -j schonberglab -p 2 -r inf'];
disp(['-- Execute: ' command])
system(command)
disp(['** Sending the requested group level launch files of "SUBGROUPS ' analysis_name ' - ' variance_equality ' - ' region '" for execution COMPLETED'])

end


