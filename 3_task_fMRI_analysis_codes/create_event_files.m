function create_event_files(subj)
% --------------------------------------------
% Written by Rani Gera, January 2020
% --------------------------------------------
% This script creates the events.tsv files for the HIS study, which was
% granted in principle acceptance in Neuroimage with the title:
% "Characterizing habit learning in the human brain at the individual and
% group levels: a multi-modal MRI study"
%
% The file will test whether it is being running from the server or from the
% local computer, according to the home directory (with getenv('HOME'), for
% windows replace with getenv('USERPROFILE')).
% If it is running from the server it will obviously skip the copy to server
% part.
%
% Arguments:
% subj - a cell of suject numbers (get both as numbers and as chars).
% default is all subjects in the participants list participants.tsv located
% in the BIDS folder.
%
% This file creates the following conditions:
% --------------------------------------------
% valued onset
% devalued onset
% rest onset
% valued (entire block)
% devalued (entire block)
% rest (entire block)

%% PARAMETERS
% Determine whether it is running on the server or my local mac according to the home directory
homeFolderLocal = '/Users/ranigera';
homeFolderServer = '/export/home/shirangera';
if strcmp(getenv('HOME'), homeFolderLocal)
    runningOnServer = 0;
elseif strcmp(getenv('HOME'), homeFolderServer)
    runningOnServer = 1;
else
    error('The function did not recognize where it is run from, adjust paths in the function parameters.')
end

% DIRECTORIES:
if runningOnServer
    % data:
    behavDataFolder    = '/export2/DATA/HIS/HIS_server/behavior/';
    % output folders:
    localOutputFolder  = '/export2/DATA/HIS/HIS_server/BIDS/';
    % file  with exclusions:
    fileWithIncludedParticipants = '/export2/DATA/HIS/HIS_server/BIDS/participants.tsv';
else
    % data:
    behavDataFolder    = '/Users/ranigera/HIS_DATA_Local/behavior/';
    % output folders:
    localOutputFolder  = '/Users/ranigera/HIS_DATA_Local/BIDS/';
    serverOutputFolder = 'shirangera@boost.tau.ac.il:/export2/DATA/HIS/HIS_server/BIDS/';
    % file  with exclusions:
    fileWithIncludedParticipants = '/Users/ranigera/HIS_DATA_Local/BIDS/participants.tsv';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GET PARTICIPANTS

% assemble participant list:
if nargin < 1
    subFolders = dir([behavDataFolder 'sub*']);
    subj = cellfun(@(x) x(end-2:end), {subFolders.name},'UniformOutput',false)';
else
    subj = cellfun(@num2str, subj, 'UniformOutput', false);
end
% get exclusion list (from the python file) and remove excluded subjects from the list:
InclusionFileContent = fileread(fileWithIncludedParticipants);
for i = 1:length(subj)
    if isempty(strfind(InclusionFileContent, subj{i}))
        subj{i} = [];
    end
end
subj(cellfun(@isempty, subj)) = [];

% Assign groups:
group    = [ones(1,sum(str2double(subj)<200)) ones(1,sum(str2double(subj)>200))*2];

for  i=1:length(subj)
    %% LOAD DATA
    subjX=char(subj(i)); % which subject?
    fprintf (['\n** Create events.tsv files for PARTICIPANT ' subjX ':\n']);
    groupX = group(i); % which group did the subject belong?
    try
        switch groupX % get the specifics according to the group (1 vs 3 days)
            case 1
                session   = {'01'};
                groupName = {'1'};%{'1-day'};
            case 2
                session = {'01'; '02'; '03'};
                groupName = {'3'};%{'3-day'};
        end
        
        for ii = 1:length(session)
            sessionX = char(session(ii,1));
            % load task data (collected in the MRI):
            load ([behavDataFolder 'sub-' num2str(subjX) '/1-data/sub-' num2str(subjX) '_HIS_MRI_' groupName{:} 'day_session-' num2str(sessionX(end-1:end)) '.mat']);
            
            % training:
            % --------------------
            % iterate over runs:
            for runX = 1:max(data.training.run)
                disp (['- sesseion-' sessionX(end) ', task-training, run-0' num2str(runX)]);
                onset = repelem(data.training.onsets.block(data.training.run == runX),2)'; % double the onsets - one time to model the block onset and one time for modeling the entire block.
                duration = zeros(40,1);
                duration(2:2:40) = data.training.durations.blocks(data.training.run == runX); % inter-mix zeros with the durations to model block onset and the entire blocks.
                
                trial_type = repelem(data.training.value(data.training.run == runX),2)';
                for ind = 1:2:40
                    trial_type{ind} = [trial_type{ind} '_onset'];
                end
                training_T = table(onset, duration, trial_type);
                
                fileToWrite = fullfile(localOutputFolder, ['sub-' num2str(subjX)], ['ses-' sessionX(end)], 'func', ['sub-' num2str(subjX) '_ses-' sessionX(end) '_task-training_run-0' num2str(runX) '_events.txt']);
                fileToWrite_tsv = strrep(fileToWrite, '.txt', '.tsv');
                writetable(training_T, fileToWrite, 'Delimiter', '\t');
                movefile(fileToWrite, fileToWrite_tsv)
                
                % If not running from the server copy to the right location on the server (inside the BIDS):
                if ~runningOnServer
                    targetServerFolder = fullfile(serverOutputFolder, ['sub-' num2str(subjX)], ['ses-' sessionX(end)], 'func', filesep);
                    system(['rsync -r -a -u --update ' fileToWrite_tsv ' ' targetServerFolder]);
                end
            end
            
            clear onset duration trial_type
            % extinction:
            % --------------------
            if isfield(data,'extinction')
                disp (['- sesseion-' sessionX(end) ', task-extinction']);
                onset = repelem(data.extinction.onsets.block,2)'; % double the onsets - one time to model the block onset and one time for modeling the entire block.
                duration(2:2:18) = data.extinction.durations.blocks; % inter-mix zeros with the durations to model block onset and the entire blocks.
                duration = duration';
                
                trial_type = repelem(data.extinction.value,2)';
                for ind = 1:2:18
                    trial_type{ind} = [trial_type{ind} '_onset'];
                end
                extinction_T = table(onset, duration, trial_type);
                
                fileToWrite = fullfile(localOutputFolder, ['sub-' num2str(subjX)], ['ses-' sessionX(end)], 'func', ['sub-' num2str(subjX) '_ses-' sessionX(end) '_task-extinction_events.txt']);
                fileToWrite_tsv = strrep(fileToWrite, '.txt', '.tsv');
                writetable(extinction_T, fileToWrite, 'Delimiter', '\t')
                movefile(fileToWrite, fileToWrite_tsv)
                
                % If not running from the server copy to the right location on the server (inside the BIDS):
                if ~runningOnServer
                    targetServerFolder = fullfile(serverOutputFolder, ['sub-' num2str(subjX)], ['ses-' sessionX(end)], 'func', filesep);
                    system(['rsync -r -a -u --update ' fileToWrite_tsv ' ' targetServerFolder]);
                end
            end
            
            clear onset duration trial_type
            % reacquisition:
            % --------------------
            if isfield(data,'reacquisition')
                disp (['- sesseion-' sessionX(end) ', task-reacquisition']);
                onset = repelem(data.reacquisition.onsets.block,2)'; % double the onsets - one time to model the block onset and one time for modeling the entire block.
                duration(2:2:18) = data.reacquisition.durations.blocks; % inter-mix zeros with the durations to model block onset and the entire blocks.
                duration = duration';
                
                trial_type = repelem(data.reacquisition.value,2)';
                for ind = 1:2:18
                    trial_type{ind} = [trial_type{ind} '_onset'];
                end
                reacquisition_T = table(onset, duration, trial_type);
                
                fileToWrite = fullfile(localOutputFolder, ['sub-' num2str(subjX)], ['ses-' sessionX(end)], 'func', ['sub-' num2str(subjX) '_ses-' sessionX(end) '_task-reacquisition_events.txt']);
                fileToWrite_tsv = strrep(fileToWrite, '.txt', '.tsv');
                writetable(reacquisition_T, fileToWrite, 'Delimiter', '\t')
                movefile(fileToWrite, fileToWrite_tsv)
                
                % If not running from the server copy to the right location on the server (inside the BIDS):
                if ~runningOnServer
                    targetServerFolder = fullfile(serverOutputFolder, ['sub-' num2str(subjX)], ['ses-' sessionX(end)], 'func', filesep);
                    system(['rsync -r -a -u --update ' fileToWrite_tsv ' ' targetServerFolder]);
                end
            end
        end
    catch
        disp(['COULD NOT CREATE FILES FOR SUBJECT: ' subjX])
    end 
end
fprintf('\n** creating event.tsv files completed.\n')
end