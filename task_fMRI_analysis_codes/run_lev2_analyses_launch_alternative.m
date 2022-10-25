function run_lev2_analyses_launch_alternative(model, analysis_name, subjects)

% Created by Rani Gera, February 2020.
%
% I MADE THIS ALTERNATIVE TO OVERCOME A PROBLEM WITH RUNNING THE LAUNCH FILES.
%
% Arguments:
% subjects - is a vector of subject numbers

%% Parameters:
% ------------------------------
launchdir = '/export2/DATA/HIS/HIS_server/codes/launchfiles';
prefix = ['second_model' model '_' analysis_name];

%% input check:
% ------------------------------
if nargin < 3
    error('The function requires all 3 input argument model (analysis_name, subjects).')
end

%% runnning the launch.txt files
% ------------------------------
disp('** Sending THE ALTERNATIVE TO the requested second level launch files for execution:')
if ischar(subjects) && strcmp(subjects,'all')
    error('this function is not suitable to run all together')
elseif isnumeric(subjects)
    for sub = subjects
        try
        file = dir(fullfile(launchdir,[prefix '_sub-' num2str(sub) '_launch.txt']));
        file = {file.name};
        
        fid = fopen(fullfile(launchdir, file{:}));
        tline = fgetl(fid);
        fullLine = [tline ' &'];
        while ischar(tline)
            disp(['-- Execute: ' fullLine]);
            system(fullLine);
            tline = fgetl(fid);
            fullLine = [tline ' &'];
        end
        fclose(fid);
        catch
            warning(['Was not executed for subject: ' num2str(sub) '. Probabely there is no such subject.']);
        end
    end    
end
disp(['** Sending THE ALTERNATIVE TO the requested second level launch files of "' analysis_name '" for execution COMPLETED'])

end


