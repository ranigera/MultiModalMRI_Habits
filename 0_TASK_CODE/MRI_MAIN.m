% clear and load basic variables:
commandwindow
clear all
path(path, 'functions');
varTask = defineBasicVars([]);

% Load relevant task list:
if varTask.sub_ID < 200
    list = {'(scan a)', 'RESTING STATE 1', '(scan b)', 'TASK RUN 1', 'TASK RUN 2', '(exit)', 'TASK RUN 20', 'TASK RUN 30', '(scan c)', 'RESTING STATE 2', '(scan d)'};
else
    switch varTask.session
        case 1
            list = {'(scan a)', 'RESTING STATE 1', '(scan b)', 'TASK RUN 1', 'TASK RUN 2', 'TASK RUN 3', 'TASK RUN 4', '(exit)', '(scan c)'};
        case 2
            list = {'(scan a)', 'TASK RUN 1', 'TASK RUN 2', 'TASK RUN 3', 'TASK RUN 4', '(exit)', '(scan b)'};
        case 3
            list = {'(scan a)', 'TASK RUN 1', 'TASK RUN 2', 'TASK RUN 3', 'TASK RUN 4', '(exit)', 'TASK RUN 20', 'TASK RUN 30', '(scan b)', 'RESTING STATE 2', '(scan c)'};
    end
end

UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize'); %get the default font size for dialog box
set(0, 'DefaultUIControlFontSize', 14); % set font size for dialog box.

% Initiate variables:
dynamicList = list;
currentTaskInd = 1;
operate = 1;
readyToFinish = 0; % will change after it got to the final task of the day.
while operate
    % add a star to mark the suggested next phase:
    if dynamicList{currentTaskInd}(end) ~= '*' %in case it is already marked.
        dynamicList{currentTaskInd} = [dynamicList{currentTaskInd} ' *'];
    end
    if strcmp(dynamicList{end}(end), '*') %i.e. if the last phase was marked.
        readyToFinish = 1;
    end
    
    [indx,tf] = listdlg('ListSize',[250,200],'Name','Choose stage', 'PromptString', 'Select an option', 'CancelString', 'Cancel', 'SelectionMode','single', 'ListString',dynamicList, 'InitialValue', currentTaskInd);
    
    if tf == 0
        error('*** Running STOPPED by the experimenter ***')
    end
    
    isTask = ~strcmp(dynamicList{indx}(1), '('); %i.e, a task/resting-state.
    performTask = 0;
    if isTask
        performTask = toPerformTask(dynamicList{indx}); % Check that the task is the one that should be performed now.
    end
    if performTask
        eyeTracker = isEyeTracker();
        switch list{indx}
            %=================================
            %% (1) anatomical scans
            %=================================
            % MPRAGE

            %=================================
            %% (2) field map scan - first day
            %=================================
            % No running code.
            
            %=================================
            %% (3) resting state - first day
            %=================================
            case 'RESTING STATE 1'
                varTask = RestingState_imaging(varTask, 1,eyeTracker);

            %=================================
            %% (4) DTI scans
            %=================================
            % No running code.

            %=================================
            %% (5) Running the MRI task run by run
            %=================================
            %% (5a) run 1
            case 'TASK RUN 1'
                varTask = runTaskMRI(varTask,'fo',1,eyeTracker);
            %% (5b) run 2
            case 'TASK RUN 2'
                varTask = runTaskMRI(varTask,'fo',2,eyeTracker);
            %% (5c) run 3
            case 'TASK RUN 3'
                varTask = runTaskMRI(varTask,'fo',3,eyeTracker);
            %% (5d) run 4
            case 'TASK RUN 4'
                varTask = runTaskMRI(varTask,'fo',4,eyeTracker);
                
            %% EXIT the Scanner

            %=================================
            %% (6) Relevant only for the last day:
            %=================================
            %% (6a)
            case 'TASK RUN 20'
                varTask = runTaskMRI(varTask,'ex',20, eyeTracker);
            %% (6b)
            case 'TASK RUN 30'
                varTask = runTaskMRI(varTask,'ra',30, eyeTracker);

            %=================================
            %% (7)  anatomical scans
            %=================================
            % MPRAGE & FLAIR

            %=================================
            %% (8) field map scan - first day
            %=================================
            % No running code.

            %=================================
            %% (9)  resting state - last day
            %=================================
            case 'RESTING STATE 2'
                varTask = RestingState_imaging(varTask, 2, eyeTracker);
            %=================================
            %% (10) DTI scans
            %=================================

            %% EXIT the Scanner
        end
        %write to log file:
        writeLog(['SUBJECT ' num2str(varTask.sub_ID) ' - ' list{indx} ' - completed'])
        pressEnter
    end
    % write to log file for a non-task scan (V can be taken off):
    if ~isTask
        writeLog(['SUBJECT ' num2str(varTask.sub_ID) ' - ' list{indx} ' - checked  '])
    end
    
    % assign relevant marker + write to log:
    if strcmp(dynamicList{indx}(end), '*') && (performTask || ~isTask)
        dynamicList{indx}(end) = 'V';
    elseif ~isTask && strcmp(dynamicList{indx}(end), 'V')  % i.e., a non-task scan (V can be taken off).
        dynamicList{indx} = dynamicList{indx}(1:end-2);
    elseif performTask || ~isTask
        dynamicList{indx} = [dynamicList{indx} ' V'];
    end
    
    %update index for suggested next task
    if dynamicList{currentTaskInd}(end) == 'V' && currentTaskInd < numel(dynamicList)
        currentTaskInd = currentTaskInd + 1;
    end
    
    if strcmp(dynamicList{end}(end), 'V') && readyToFinish
        operate = strcmp(questdlg('Do you want finish and exit?','Completed?','Yes','No','Yes'), 'No');
    end
    
end
fprintf('\n-- Running ended by the experimenter after going through all stages --\n')
set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak); %return default text size for dialog box.

