function run_group_lev_individual_diff_across_all2(model, analysis_name, lev1CopeNum, region)
%run_group_lev_individual_diff_across_all(model, analysis_name, lev1CopeNum, region)
% Created by Rani Gera, May 2020.
%
% This function will run the launch.txt files that were created by
% create_group_lev_fsf_individual_diff_across_all. Each launch file includes
% running the relevant feat command on the relevant fsf.
%
% Arguments:
% ----------------------
% * model_name - the name of the (lev1) model
% relevant models:
% '001'
% * analysis_name - The name of the level 2 analysis:
% ralevant analysis names:
% 'extinction_vs_last_run'
% * region - the region in the brain for in the analysis:
% options: 'whole_brain', 'putamen, 'caudate_head', 'vmPFC's.
% * variance_equality:
% 'equal_var_assumed'
% 'unequal_var_assumed'

%% Parameters:
% ------------------------------
% Define variables according to the inputs:
switch lev1CopeNum
    case 12
        onsetsOrWholeBlocks = 'onsets'; % (task vs rest onsetes)
    case 18
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

% edit analysis name:
analysis_name = ['individual-differences_across-all_' analysis_name];

launchdir = '/export2/DATA/HIS/HIS_server/codes/launchfiles';
file = ['noFieldMapParticipants_group_model' model '_' analysis_name '_based-on-' onsetsOrWholeBlocks '_' region '_launch.txt'];

%% input check:
% ------------------------------
if nargin < 1
    error('The function requires 4 input arguments: model, analysis_name, region.')
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
disp(['** Sending the requested group level launch files of individual diferences across all subjects - "' analysis_name ' - ' region '" for execution COMPLETED'])

end


