function [] = run_SpaceMarket_fMRI()
    % initialize task variables
    taskStruct = initTaskStruct();
    % the number of scaning sessions
    taskStruct.numSessions = 2;
    % the duration (in seconds) for each session
    taskStruct.MAX_FMRI_RUNTIME = 9*60;
    
    % subejct & session ID info
    taskStruct.subID = input('Participant number :\n','s');
    taskStruct.sessionID = input('Session number :\n','s');
    
    % initialize the task strcutures for practice and test
    taskStruct.outputFolder = fullfile('..', 'data');
    % check to see if the output folder exists
    if exist(taskStruct.outputFolder, 'dir') == 0
        % folder does not exist - create it
        mkdir( taskStruct.outputFolder );
    end
    taskStruct.fileName = [taskStruct.subID '_Sub_session_' num2str(taskStruct.sessionID) '_fMRI_' datestr(now, 'mm-dd-yyyy_HH-MM-SS')];
    
    % initialize the IO for the task
    ioStruct = initIOStruct();
    
    % accumulate the total number of points earned across all sessions
    totalPoints = 0;
    % loop through each scanning session
    for sI = 1 : taskStruct.numSessions
        % run the session
        taskStruct.sessionData{sI} = runSession(taskStruct, ioStruct);
        totalPoints = totalPoints + round(nansum( taskStruct.sessionData{sI}.trials.outcomeMag ) );
        % save data and clean up
        save(fullfile(taskStruct.outputFolder, taskStruct.fileName), 'taskStruct', 'ioStruct');
    end
    
    % finish game
    Screen(ioStruct.wPtr, 'Flip');
    % show inter-block information
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    DrawFormattedText(ioStruct.wPtr, ['You''re done.\n\n You earned a total of ' num2str(totalPoints) ' points.\n\n Please try to stay still and wait for the experimenter.'], 'center', 'center');
    % show prompt
    Screen(ioStruct.wPtr, 'Flip');

    % prompt for quit code
    RestrictKeysForKbCheck( ioStruct.respKey_Quit );
    [~, keyCode] = KbWait(-3,2);

    RestrictKeysForKbCheck( [] );
    ListenChar(1); ShowCursor();
    sca; 
end

function sessionStruct = runSession(taskStruct, ioStruct)
    minTrialTime = 4;
    maxNumTrials = ceil(30 + (taskStruct.MAX_FMRI_RUNTIME / minTrialTime));
    % build a dynamic block of trials
    trials = buildTrials_dynamic(taskStruct, maxNumTrials);
    
    % wait for prompt from technician to start waiting for pulse signal
    waitForTechPrompt(ioStruct);
    
    % wait for initial pulse from scanner
    sessionStruct = struct();
    sessionStruct.startTime = waitForScannerPulse(ioStruct);
    sessionStruct.trials = [];
    
    % current trial in the current block
    tI = 1;
    % loop through the block timer
    blockEndTime = (sessionStruct.startTime + taskStruct.MAX_FMRI_RUNTIME);
    lastBreakTime = GetSecs();
    while GetSecs() < blockEndTime
        % run a trial
        trials(tI,:) = showTrial(taskStruct, ioStruct, trials(tI,:));
        sessionStruct.trials = vertcat(sessionStruct.trials, trials(tI,:));
        % save data
        save(fullfile(taskStruct.outputFolder, taskStruct.fileName), 'taskStruct', 'ioStruct', 'sessionStruct');
        % update the trial count for the total experiment
        tI = tI + 1;
        
        % should we give a short break?
        if GetSecs() > lastBreakTime + ioStruct.BREAK_ITI
            waitForBreak(ioStruct);
            lastBreakTime = GetSecs();
        end
    end % while still in current block
    sessionStruct.endTime = GetSecs();
end

% wait for experimentor input to prompt wait for scanner pulse
function secs = waitForTechPrompt(ioStruct)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    DrawFormattedText(ioStruct.wPtr, 'Waiting for technician to mark ready status.\n\n Please try to stay still.', 'center', 'center');
    RestrictKeysForKbCheck( ioStruct.respKey_Proceed );
    Screen(ioStruct.wPtr, 'Flip');
    secs = KbWait(-3,2);
    RestrictKeysForKbCheck([]);
end

% waits for the initial key-code as initial pulse from scanner
function secs = waitForScannerPulse(ioStruct)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    % wait for the scanner to send the initial pulse signal
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    DrawFormattedText(ioStruct.wPtr, 'Waiting for initiation signal from scanner.', 'center', 'center');
    RestrictKeysForKbCheck( ioStruct.pulseKey ); 
    Screen(ioStruct.wPtr, 'Flip');
    % track the initial start time
    secs = KbWait(-3, 2);
    RestrictKeysForKbCheck([]);
    
    % start the task start count-down
    for tI = 5:-1:1
        DrawFormattedText(ioStruct.wPtr, ['The game will start in\n\n' num2str(tI)], 'center', 'center');
        Screen(ioStruct.wPtr, 'Flip');
        WaitSecs(1);
    end
end

% waits for the initial key-code as initial pulse from scanner
function secs = waitForBreak(ioStruct)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    % wait for the scanner to send the initial pulse signal
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    
    % start the task start count-down
    for tI = ioStruct.BREAK_DURATION:-1:1
        DrawFormattedText(ioStruct.wPtr, ['Time for a short break.\n Please try to stay still.\n\n The game will start in\n\n' num2str(tI)], 'center', 'center');
        Screen(ioStruct.wPtr, 'Flip');
        WaitSecs(1);
    end
end

function [] = saveTaskData(taskStruct, ioStruct)
    % save data and clean up
    save(fullfile(taskStruct.outputFolder, taskStruct.fileName), 'taskStruct', 'ioStruct');
end