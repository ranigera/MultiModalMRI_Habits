function var = runTaskMRI(var, task, run, use_eyetracker)
% function var = runTaskMRI(var, task, run, use_eyetracker)
%__________________________________________________________________________
%--------------------------------------------------------------------------
%
% Free operant task with outcome devaluation procedure Tricomi et al., (2009)
% PTB 3.0.12 on matlab 2014b
%__________________________________________________________________________
%-------------------------------------------------------------------------
% last modified on AUGUST 2019 by Rani to fit an MRI experiment and
% integrating other tasks, for a Neuroimage registered report.
% modified on AUGUST 2017 by Eva

% session = different sessions collected on different days
% run = different runs run on the same days
% button to answer: -blue- -yellow- to win snacks or to move for ranking.
% -red- to confirm coice of ranking.
% -q- is the experimenter controller

% Rani - mapping task
% --------------------
% 'fo' = free operant (i.e., the training)
% 'ex' = extinction test
% 'ra' = reacquisition test
% * Notes:
% --------------------
% 'RS' = stands for "task" resting-state (running from the restingState
% function)

% data.extinction.run - was changed to be 20
% data.reacquisition.run - was set to be 30

try
    %**************************************************************************
    %%       PTB INITIALIZATION/PARAMETER SETUP
    %**************************************************************************
  
    commandwindow
    % add the function folder to the path just for this session
    path(path, 'functions');
    
    % relies any disables/restrictions of keys.
    DisableKeysForKbCheck([]);
    RestrictKeysForKbCheck([]);
    
    if ~exist('run', 'var')
        run = 0;
    end
    if ~exist('use_eyetracker', 'var')
        use_eyetracker = 1;
    end

    eyeTrackerTasks = {'fo', 'ex', 'ra'};
    
    % get the response device index
    id = GetKeyboardIndices();
    %disp ('list of devices:' )
    %for i = 1:length(id)
    %
    %    nameX = cellstr(names(i));
    %    idX   = id(i);
    %    disp (['ID number: ' idX  nameX])
    %
    %end
    var.deviceIndex = min(id);
    %var.deviceIndex = input('***input*** response device ID number (check list of devices above): ');
    %---
    
    % enter the task variables
    % -------------------------
    if ~isfield(var, 'sub_ID') % if the subID was not already entered and thus exist in the workspace.
        var.sub_ID = input('***input*** SUBJECT NUMBER: ');
    end
    % check validity of SUBJECT number:
    while isempty(var.sub_ID) || ~isa(var.sub_ID,'double') || var.sub_ID <= 100 || var.sub_ID >= 300 || var.sub_ID == 200
        var.sub_ID = input('SUBJECT NUMBER must be 101-199 or 201-299. SUBJECT NUMBER: ');
    end
    if var.sub_ID > 100 && var.sub_ID < 200
        var.session = 1;
        var.training = 1;
        var.runs = 2;
    elseif var.sub_ID > 200 && var.sub_ID < 300
        if ~isfield(var, 'session') % if the session was not already entered and thus exist in the workspace.
            var.session = input('***input*** SESSION NUMBER (1, 2 or 3 session day): '); % 1,2,or 3 session
            % check validity of SESSION number:
            while isempty(var.session) || ~ismember(var.session,1:3)
                var.session = input('SESSION NUMBER must be 1, 2 or 3. SESSION NUMBER: '); % 1,2,or 3 session
            end
        end
        var.training = 3;
        var.runs = 4;
    end
    
    % exit in case completed the rquired number of runs:
    if strcmp(task, 'fo') && run > var.runs
        disp('The participant completed the number of runs required at this stage')
        return
    end
    
    % check that task variable make sense
    var = inputCheck(var,1,task,run); % check that the file does not exist and that the last session file does exist
    
    % initialize task parameters
    [var, data] = initTask(var);
    
    % Initializing eye tracking system %
    try
        if ismember(task, eyeTrackerTasks)
            [edfFile, el] = initializeEyeTracker(use_eyetracker, var, task, run);
            Screen('FillRect', var.w, [180 180 180]);
        end
    catch
        Screen('CloseAll');
        fclose('all');
        disp('*** EYE TRACKER was not loaded successfully ***')
        decision = input('Do you want to continue WITHOUT EYE TRACKER (y/[n])?','s');
        if strcmp(decision,'y')
            use_eyetracker = 0;
            edfFile = '';
            [var, data] = initTask(var);
        else
            error('Running ABORTED!')
        end
    end
    
    %-- Rani added the condition for if it crashes...
    if exist(var.resultFile, 'file')
        save (var.resultFile, 'data', '-append');
    else
        save(var.resultFile,'data');
    end
    
    % make sure no key is pressed before beginning a task:
    while KbCheck(-3,2)
    end
    
    switch task
        %**************************************************************************
        %                      FREE OPERANT TRAINING                               %
        %**************************************************************************
        case 'fo'
            
            % randomize list for the run
            % each learning run has 12 task blocks and eight rest blocks.
            condition = [1  1  1  1  1  1  2  2  2  2  2  2  0  0  0  0  0  0  0  0 ]; % 1 = sweet 2 = salty; 0 = rest
            duration  = [40 40 20 20 20 20 40 40 20 20 20 20 20 20 20 20 20 20 20 20];% the duration of each block is 20s for rest and 20 or 40 for active blocks
            [var.condition, var.duration] = loadRandList(condition, duration);

            %%%%%%%%%%%%%%%% sync procedure and time initialization %%%%%%%%%%%%%%%%%%%
            trial = (run-1) * length(condition) + 1; % prepare the trial number according to the run
            
            RestrictKeysForKbCheck([]); % allow all butttons as inputs
            if run == 1
                showInstruction(var,'instructions/waitMRI.txt'); % experiment about to start
            else
                showInstruction(var,'instructions/newRunMRI.txt'); % next run is about to start
            end
            
            noResp = 1;
            while noResp
                down = KbCheck(-3,2);
                if down
                    noResp = 0;
                end
            end
            showInstruction(var,'instructions/startingSoon.txt'); % next run is about to start
            
            % wait for trigger
            while 1
                [down, ~, keycode] = KbCheck(-1);
                if down && keycode(var.pulseKeyCode)
                    break;
                end
            end
            
            % once the task is on we just check the task relevant button to avoid any interference
            RestrictKeysForKbCheck([var.leftKey, var.rightKey, var.centerLeftKey, var.centerRightKey]);
            
            var.time_MRI = GetSecs(); % absolute reference of the experiment beginning
            var.ref_end = 0;
            
            if use_eyetracker
                % start recording eye position
                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.05);
                Eyelink('StartRecording');
                WaitSecs(0.05);
                Eyelink('Message', Eventflag(GenFlags.RunStart.str,task,run,trial,var.time_MRI)); % mark start time in file
            end
            
            %%%%%%%%%%%%%%%% lead in screen for 4 s (is 4 s) %%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + var.fixationDurationBeforeRun;
            data.training.onsets.leadIn(run) = GetSecs -var.time_MRI;
            data.training.durations.leadIn(run) = displayITI(var);
                       
            for ii = 1:length(var.condition)
                                
                % show block
                var.ref_end = var.ref_end + var.duration(ii); % 20 or 40 s
                data.training.onsets.block(trial) = GetSecs - var.time_MRI; % get onset
                
                if use_eyetracker
                    Eyelink('Message', Eventflag(GenFlags.TrialStart.str,task,run,trial,var.time_MRI)); % mark start time in file
                end

                [RT, pressed_correct, pressed_all,...
                    ACC, RT_all, Button,...
                    reward, potential_rewards, potential_rewards_time,...
                    duration] = drawnActiveScreen (var,ii);
                
                if use_eyetracker
                    Eyelink('Message', Eventflag(GenFlags.TrialEnd.str,task,run,trial,var.time_MRI)); % mark start time in file
                end

                % log data
                data.training.stPressRT(trial)           = RT;
                data.training.raw_press(trial)           = pressed_correct;
                data.training.pressFreq(trial)           = pressed_correct/duration; % press per second
                data.training.raw_all_press(trial)       = pressed_all;
                data.training.all_pressFreq(trial)       = pressed_correct/duration; % press per second
                data.training.reward(trial)              = reward;
                data.training.blockDetails(trial).ACC    = ACC;
                data.training.blockDetails(trial).RT     = RT_all;
                data.training.blockDetails(trial).button = Button;
                data.training.blockDetails(trial).potential_rewards = potential_rewards;
                data.training.blockDetails(trial).potential_rewards_time = potential_rewards_time;
                data.training.durations.blocks(trial)    = duration;
                
                data.training.condition(trial)           = var.condition(ii);
                data.training.block    (trial)           = ii;
                data.training.run      (trial)           = run;
                data.training.session  (trial)           = var.session;
                data.training.subID    (trial)           = var.sub_ID;
                
                if var.condition(ii) == var.devalued
                    data.training.value {trial}         = 'devalued';
                elseif var.condition(ii) == 0
                    data.training.value {trial}         = 'baseline';
                else
                    data.training.value {trial}         = 'valued';
                end
                
                % save at the end of each active block
                save(var.resultFile, 'data', '-append');
                
                trial = trial+1;
            end
            
            %%%%%%%%%%%%%%%% lead out fixation screen for 8 s (is 8 s) %%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + var.fixationDurationAfterRun;
            data.training.onsets.leadOut(run) = GetSecs -var.time_MRI;
            if use_eyetracker
                Eyelink('Message',Eventflag(GenFlags.FixationStart.str,task,run,trial,var.time_MRI));
            end
            data.training.durations.leadOut(run) = displayITI(var);
            data.training.onsets.postRunITIended(run) = GetSecs -var.time_MRI;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Finish the run/task %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if use_eyetracker
                Eyelink('Message', Eventflag(GenFlags.RunEnd.str,task,run,trial,var.time_MRI)); % mark start time in file
            end
            
            showWinnings(var, data, 'training'); % present participants winnings.
            data.training.onsets.rewardPresentationCompleted(run) = GetSecs -var.time_MRI;

            %**************************************************************************
            %                        DEVALULATION PROCEDURE                           %
            %**************************************************************************
            if var.runs == run % if it's the last daily run
                if (var.training == 1 || (var.training ==3 && var.session == 3)) % only if it's athe last session for the experimental group
                    % show instruction for the devaluation procedure
                    showBonus(var, data);
                    data.training.onsets.bonusPresentationCompleted = GetSecs -var.time_MRI;
                    showInstruction(var,'instructions/goOutToEatNow.txt');
                else
                    showInstruction(var,'instructions/goOutToEatNow.txt');
                end
                
                waitOrPressKey(5, 12); % waitOrPressKey(minWait, maxWait)
            end
            
            data = endRun(var, data);
            data.training.onsets.screenClosed(run) = GetSecs -var.time_MRI;
            
            finishEyeTracking(use_eyetracker, edfFile, var, task, run); % close and save eyetracker file
            save(var.resultFile, 'data', '-append');
            saveByStage(var, data, task, run); % backup saving a seperate file for each step
            if var.runs == run
                CopyOutputToDropbox4(var.sub_ID);
            end
            disp(['Run ' num2str(run) ' completed']);
            
            %**************************************************************************
            %                           EXTINCTIION TEST                              %
            %**************************************************************************
        case 'ex'
            
            if var.training == 1 || (var.training ==3 && var.session == 3) % only if it's the last training session for the experimental group
                %disp ('Extinction procedure is about to start...')
                
                % randomize list for the run
                % the extinction run has 9 task blocks and 3 rest blocks.
                condition = [1  1  1  2  2  2  0  0  0 ]; % 1 = sweet 2 = salty; 0 = rest
                duration  = [20 20 20 20 20 20 20 20 20];% the duration of each block is 20s
                [var.condition, var.duration] = loadRandList(condition, duration);

                %%%%%%%%%%%%%%%% sync procedure and time initialization %%%%%%%%%%%%%%%%%%%
                trial = 1;
                
                RestrictKeysForKbCheck([]); % re-allow all keys to be read as inputs
                
                showInstruction(var,'instructions/newRunMRI.txt');
                
                noResp = 1;
                while noResp
                    down = KbCheck(-3,2);
                    if down
                        noResp = 0;
                    end
                end
                showInstruction(var,'instructions/startingSoon.txt'); % next run is about to start
                
                % wait for trigger
                while 1
                    [down, ~, keycode] = KbCheck(-1);
                    if down && keycode(var.pulseKeyCode)
                        break;
                    end
                end
                                
                % once the task is on we just check the task relevant button to avoid any interference
                RestrictKeysForKbCheck([var.leftKey, var.rightKey, var.centerLeftKey, var.centerRightKey]);
                
                var.time_MRI = GetSecs(); % absolute reference of the experiment beginning
                var.ref_end = 0;
                
                if use_eyetracker
                    % start recording eye position
                    Eyelink('Command', 'set_idle_mode');
                    WaitSecs(0.05);
                    Eyelink('StartRecording');
                    WaitSecs(0.05);
                    Eyelink('Message', Eventflag(GenFlags.RunStart.str,task,run,trial,var.time_MRI)); % mark start time in file
                end
                
                %%%%%%%%%%%%%%%% lead in screen for 4 s (is 4 s) %%%%%%%%%%%%%%%%%%%%%%
                var.ref_end = var.ref_end + var.fixationDurationBeforeRun;
                data.extinction.onsets.leadIn = GetSecs -var.time_MRI;
                data.extinction.durations.leadIn = displayITI(var);
                     
                for trial = 1:length(var.condition)
                    
                    % show block
                    var.ref_end = var.ref_end + var.duration(trial); % 20 or 40 s
                    data.extinction.onsets.block(trial) = GetSecs - var.time_MRI; % get onset
                    
                    if use_eyetracker
                        Eyelink('Message', Eventflag(GenFlags.TrialStart.str,task,run,trial,var.time_MRI)); % mark start time in file
                    end
                    
                    [RT, pressed_correct, pressed_all,...
                        ACC, RT_all, Button, duration] = drawnExtinctionScreen (var,trial);
                    
                    if use_eyetracker
                        Eyelink('Message', Eventflag(GenFlags.TrialEnd.str,task,run,trial,var.time_MRI)); % mark start time in file
                    end

                    % log data
                    data.extinction.stPressRT(trial)           = RT;
                    data.extinction.raw_press(trial)           = pressed_correct;
                    data.extinction.pressFreq(trial)           = pressed_correct/duration; % press per second
                    data.extinction.raw_all_press(trial)       = pressed_all;
                    data.extinction.all_pressFreq(trial)       = pressed_correct/duration; % press per second
                    data.extinction.blockDetails(trial).ACC    = ACC;
                    data.extinction.blockDetails(trial).RT     = RT_all;
                    data.extinction.blockDetails(trial).button = Button;
                    data.extinction.durations.blocks(trial)    = duration;
                    
                    data.extinction.condition(trial)           = var.condition(trial);
                    data.extinction.block    (trial)           = trial;
                    data.extinction.run      (trial)           = 20;
                    data.extinction.session  (trial)           = var.session;
                    data.extinction.subID    (trial)           = var.sub_ID;
                    
                    if var.condition(trial) == var.devalued
                        data.extinction.value {trial}          = 'devalued';
                    elseif var.condition(trial) == 0
                        data.extinction.value {trial}          = 'baseline';
                    else
                        data.extinction.value {trial}          = 'valued';
                    end
                    
                    % save at the end of each extiction block
                    save(var.resultFile, 'data', '-append');
                    
                end
                
                %%%%%%%%%%%%%%%% lead out fixation screen for 8 s (is 8 s) %%%%%%%%%%%%%%%%%%%%%%
                var.ref_end = var.ref_end + var.fixationDurationAfterRun;
                data.extinction.onsets.leadOut = GetSecs -var.time_MRI;
                if use_eyetracker
                    Eyelink('Message',Eventflag(GenFlags.FixationStart.str,task,run,trial,var.time_MRI));
                end
                data.extinction.durations.leadOut = displayITI(var);
                data.extinction.onsets.postRunITIended = GetSecs -var.time_MRI;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Finish the run/task %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if use_eyetracker
                    Eyelink('Message', Eventflag(GenFlags.RunEnd.str,task,run,trial,var.time_MRI)); % mark start time in file
                end
                
                showWinnings(var, data, 'extinction');% present participants winnings (or no winnings in thhis case).
                data.extinction.onsets.rewardPresentationCompleted = GetSecs -var.time_MRI;

                data = endRun(var, data);
                data.extinction.onsets.screenClosed = GetSecs -var.time_MRI;
                finishEyeTracking(use_eyetracker, edfFile, var, task, run); % close and save eyetracker file
                save(var.resultFile, 'data', '-append');
                saveByStage(var, data, task);  % backup saving a seperate file for each step
                CopyOutputToDropbox4(var.sub_ID);
                disp(['Run ' num2str(run) ' completed']);
            end
            
            %**************************************************************************
            %                           REACQUISITION TEST                              %
            %**************************************************************************
        case 'ra'
            
            if var.training == 1 || (var.training ==3 && var.session == 3) % only if it's the last training session for the experimental group
                disp ('Reacquisiotion procedure is about to start...')
                
                % randomize list for the run
                % the reacquisition run has 9 task blocks and 3 rest blocks.
                condition = [1  1  1  2  2  2  0  0  0 ]; % 1 = sweet 2 = salty; 0 = rest
                duration  = [20 20 20 20 20 20 20 20 20];% the duration of each block is 20s
                [var.condition, var.duration] = loadRandList(condition, duration);

                %%%%%%%%%%%%%%%% sync procedure and time initialization %%%%%%%%%%%%%%%%%%%
                trial = 1;

                RestrictKeysForKbCheck([]); % re-allow all keys to be read as inputs
                
                showInstruction(var,'instructions/newRunMRI.txt');
                
                noResp = 1;
                while noResp
                    down = KbCheck(-3,2);
                    if down
                        noResp = 0;
                    end
                end
                showInstruction(var,'instructions/startingSoon.txt'); % next run is about to start
                
                % wait for trigger
                while 1
                    [down, ~, keycode] = KbCheck(-1);
                    if down && keycode(var.pulseKeyCode)
                        break;
                    end
                end
                                
                % once the task is on we just check the task relevant button to avoid any interference
                RestrictKeysForKbCheck([var.leftKey, var.rightKey, var.centerLeftKey, var.centerRightKey]);
                
                var.time_MRI = GetSecs(); % absolute reference of the experiment beginning
                var.ref_end = 0;
                
                if use_eyetracker
                    % start recording eye position
                    Eyelink('Command', 'set_idle_mode');
                    WaitSecs(0.05);
                    Eyelink('StartRecording');
                    WaitSecs(0.05);
                    Eyelink('Message', Eventflag(GenFlags.RunStart.str,task,run,trial,var.time_MRI)); % mark start time in file
                end
                
                %%%%%%%%%%%%%%%% lead in screen for 4 s (is 4 s) %%%%%%%%%%%%%%%%%%%%%%
                var.ref_end = var.ref_end + var.fixationDurationBeforeRun;
                data.reacquisition.onsets.leadIn = GetSecs -var.time_MRI;
                data.reacquisition.durations.leadIn = displayITI(var);
                
                for trial = 1:length(var.condition)
                    
                    % show block
                    var.ref_end = var.ref_end + var.duration(trial); % 20 or 40 s
                    data.reacquisition.onsets.block(trial) = GetSecs - var.time_MRI; % get onset
                    
                    if use_eyetracker
                        Eyelink('Message', Eventflag(GenFlags.TrialStart.str,task,run,trial,var.time_MRI)); % mark start time in file
                    end

                    [RT, pressed_correct, pressed_all,...
                        ACC, RT_all, Button,...
                        reward, potential_rewards, potential_rewards_time,...
                        duration] = drawnActiveScreen (var,trial);
                    
                    if use_eyetracker
                        Eyelink('Message', Eventflag(GenFlags.TrialEnd.str,task,run,trial,var.time_MRI)); % mark start time in file
                    end

                    % log data
                    data.reacquisition.stPressRT(trial)           = RT;
                    data.reacquisition.raw_press(trial)           = pressed_correct;
                    data.reacquisition.pressFreq(trial)           = pressed_correct/duration; % press per second
                    data.reacquisition.raw_all_press(trial)       = pressed_all;
                    data.reacquisition.all_pressFreq(trial)       = pressed_correct/duration; % press per second
                    data.reacquisition.reward(trial)              = reward;
                    data.reacquisition.blockDetails(trial).ACC    = ACC;
                    data.reacquisition.blockDetails(trial).RT     = RT_all;
                    data.reacquisition.blockDetails(trial).button = Button;
                    data.reacquisition.blockDetails(trial).potential_rewards = potential_rewards;
                    data.reacquisition.blockDetails(trial).potential_rewards_time = potential_rewards_time;
                    data.reacquisition.durations.blocks(trial)    = duration;
                    
                    data.reacquisition.condition(trial)           = var.condition(trial);
                    data.reacquisition.block    (trial)           = trial;
                    data.reacquisition.run      (trial)           = 30;
                    data.reacquisition.session  (trial)           = var.session;
                    data.reacquisition.subID    (trial)           = var.sub_ID;
                    
                    if var.condition(trial) == var.devalued
                        data.reacquisition.value {trial}          = 'devalued';
                    elseif var.condition(trial) == 0
                        data.reacquisition.value {trial}          = 'baseline';
                    else
                        data.reacquisition.value {trial}          = 'valued';
                    end
                    
                    % save at the end of each extiction block
                    save(var.resultFile, 'data', '-append');
                    
                end
                
                %%%%%%%%%%%%%%%% lead out fixation screen for 8 s (is 8 s) %%%%%%%%%%%%%%%%%%%%%%
                var.ref_end = var.ref_end + var.fixationDurationAfterRun;
                data.reacquisition.onsets.leadOut = GetSecs -var.time_MRI;
                if use_eyetracker
                    Eyelink('Message',Eventflag(GenFlags.FixationStart.str,task,run,trial,var.time_MRI));
                end
                data.reacquisition.durations.leadOut = displayITI(var);
                data.reacquisition.onsets.postRunITIended = GetSecs -var.time_MRI;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Finish the run/task %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if use_eyetracker
                    Eyelink('Message', Eventflag(GenFlags.RunEnd.str,task,run,trial,var.time_MRI)); % mark start time in file
                end
                
                showWinnings(var, data, 'reacquisition'); % present participants winnings.

                data.reacquisition.onsets.rewardPresentationCompleted = GetSecs -var.time_MRI;
                finishEyeTracking(use_eyetracker, edfFile, var, task, run); % close and save eyetracker file         
                save(var.resultFile, 'data', '-append');
                saveByStage(var, data, task);  % backup saving a seperate file for each step  
                CopyOutputToDropbox4(var.sub_ID);
                disp(['Run ' num2str(run) ' completed']);
                
                % Thanking the participant and informing we we are moving to non-task scan
                showInstruction(var,'instructions/thanks.txt')
                WaitSecs(3.4) % simillar duration to the endTask function
                showInstruction(var,'instructions/goOutToEatSoon.txt');
                waitOrPressKey(5, 12); % waitOrPressKey(minWait, maxWait)

                data = endRun(var, data);
                data.reacquisition.onsets.screenClosed(run) = GetSecs -var.time_MRI;
            end
     
            %**************************************************************************
            %                           END MRI TASK                                %
            %**************************************************************************
            
    end
    
catch %#ok<*CTCH>
    % This "catch" section executes in case of an error in the "try"
    % section []
    % above.  Importantly, it closes the onscreen window if it's open.
    Screen('CloseAll');
    fclose('all');
    psychrethrow(psychlasterror);
    
end

end