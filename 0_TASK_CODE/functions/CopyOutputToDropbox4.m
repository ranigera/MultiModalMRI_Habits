function CopyOutputToDropbox4(subID)
% Copy all the output files of a subject to the dropbox "experiments
% outputs" folder in the end of the experiment\session.
% Locate it in the end of the main function of the experiment.
% Adjust for the HIS study by Rani - May 2019.

dataFolders = {'data', 'data/dataByStage', 'data/replacedFiles', 'data/eyeTrackerData', 'OSPAN/ospanData', 'SpaceMiner/data'};
targetFolders = {'1-data', '2-dataByStage', '3-replacedFiles', '4-eyeTrackerData', '5-OSPANdata', '6-spaceMinerData'};
mainPath = pwd;
targetPath = '~/Dropbox/experimentsOutput/HIS';

targetFoldersNotAcceptedFiles = {};
targetFoldersAcceptedFiles = {};
problems = {};

for i = 1:length(dataFolders)
    % Change this 3 variables according to experiment:
    FilesToCopy = fullfile(mainPath,dataFolders{i},['*' num2str(subID) '*']);
    DestinationFolder = fullfile(targetPath,targetFolders{i});
    if ~isempty(dir(FilesToCopy))
        try
            % Copy the relevant files:
            copyfile(FilesToCopy, DestinationFolder);
            targetFoldersAcceptedFiles{end+1} = targetFolders{i};
        catch
            problems{end+1} = targetFolders{i};
        end
    else
        targetFoldersNotAcceptedFiles{end+1} = targetFolders{i};
    end
end

% printing:
if ~isempty(targetFoldersAcceptedFiles)    
    fprintf('\nOutput files have been copied successfully to the following folders:\n')
    fprintf('--------------------------------------------------------------------\n')
    fprintf('%s\n', targetFoldersAcceptedFiles{:})
end
if ~isempty(targetFoldersNotAcceptedFiles)
    
    fprintf('\nThere were no files to go to the following folders:\n')
    fprintf('---------------------------------------------------\n')
    fprintf('%s\n', targetFoldersNotAcceptedFiles{:})
end
if ~isempty(problems)
    fprintf('\n** ISSUES **\n')
    fprintf('------------\n')
    fprintf('** Existed files that were supposed to be copied to the folder %s were ****NOT**** copied successfully **\n', problems{:})
end

end
