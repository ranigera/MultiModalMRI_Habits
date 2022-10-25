function taskOrderVerification(var, task, run)
% verify the order for the MRI task runs correctly:
% Not doing again the sam stage/run and not missing a stage.
% Goes by this:
% Rani - mapping task
% --------------------
% 'fo' = free operant (i.e., the training)
% 'tc' = test contingency (i.e., stimulus-outcome contingency test)
% 'wp' = winnings presentation [do not produce files, run together with 'tc' and will not be checked].
% 'dv' = devaluation [do not produce files, run together with 'tc' and will not be checked].
% 'ex' = extinction test
% 'ra' = reacquisition test
% * Notes:
% --------------------
% 'tc' also runs 'wp' and 'dv'.
% if using 'wp' it will also tun 'dv'.
% if using 'dv' it will run just 'dv'.
% 'RS' = stands for "task" resting-state (running from the restingState
% function)

%% Get the relevant list by subject number and session:
if var.sub_ID > 100 && var.sub_ID < 200
    order.files = {'fo' 'ex' 'ra'};
    order.foRuns = 2;
elseif var.sub_ID > 200 && var.sub_ID < 300
    order.foRuns = 4;
    switch var.session
        case 1
            order.files = {'fo'};
            
        case 2
            order.files = {'fo'};
            
        case 3
            order.files = {'fo' 'ex' 'ra'};
    end
end

%% get current expected file
if strcmp(task,'fo')
    currentExpectedFile = dir(strcat('data/dataByStage/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', task, '_run-', num2str(run,'%02.0f'), '_', '*', '.mat'));
else
    currentExpectedFile = dir(strcat('data/dataByStage/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', task,'_', '*', '.mat'));
end
if ~isempty(currentExpectedFile) % if expected file is not there
    disp('--> The file of this stage (or stage and run where relevant) already exists!')
    disp('--> You may have tried to run the same stage/run again.')
    toContinue = '';
    while isempty(toContinue)
        toContinue = input('Do you want to continue anyway? y/[n]: ','s');
    end
    if ~strcmp(toContinue(end), 'y')
        error('** Running aborted !!! **')
    end
end

%% Get previously expected to be formed file:
taskLoc = find(strcmp(task, order.files));
if strcmp(task,'fo') && run > 1
    lastExpectedFile = dir(strcat('data/dataByStage/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', task, '_run-', num2str(run-1,'%02.0f'), '_', '*', '.mat'));
elseif strcmp(task,'ex') || strcmp(task,'ra')
    lastExpectedFile = dir(strcat('data/dataByStage/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', order.files{taskLoc-1},'_', '*', '.mat'));
else % if it is the first task (and should be the first one, i.e. 'fo' first run:
    lastExpectedFile = 'none';
end
if isempty(lastExpectedFile) % if expected file is not there
    if strcmp(task,'fo') && run > 1
        disp(['--> The file of the last expected run - run ' num2str(run-1) ' - is not found!'])
    else
        disp(['--> The file of the last expected stage: ' order.files{taskLoc-1} ' is not found!'])
    end
    disp(['--> You may have skipped the required stage.'])
    toContinue = '';
    while isempty(toContinue)
        toContinue = input('Do you want to continue anyway? y/[n]: ','s');
    end
    if ~strcmp(toContinue(end), 'y')
        error('** Running aborted !!! **')
    end
end

end

