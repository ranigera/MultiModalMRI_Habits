function [] = run_SpaceMarket_behavioral(subID)
    % initialize task variables
    taskStruct = initTaskStruct();
    % the duration (in seconds) for the task
    taskStruct.MAX_BEHAV_RUNTIME = 15*60; % changed by Rani from 20 to 15 minutes.
    
    % subejct & session ID info (EDITED BY RANI)
    if nargin < 1
        taskStruct.subID = input('Participant number :\n','s');
    else
        taskStruct.subID = num2str(subID);
    end
    taskStruct.sessionID = '1'; % CHANGED BY RANI
    
    % initialize the task strcutures for practice and test
    taskStruct.outputFolder = fullfile('..', 'data');
    % check to see if the output folder exists
    if exist(taskStruct.outputFolder, 'dir') == 0
        % folder does not exist - create it
        mkdir( taskStruct.outputFolder );
    end
    taskStruct.fileName = [taskStruct.subID '_Sub_session_' num2str(taskStruct.sessionID) '_behav_' datestr(now, 'mm-dd-yyyy_HH-MM-SS')];
    % initialize the IO for the task
    ioStruct = initIOStruct();
    
    % build blocked sets of trials to switch between at given timepoints
    % run 8 blocks over 24 minutes
    numBlocks = 8;
    minTrialTime = 4;
    maxNumTrials = ceil(30 + (taskStruct.MAX_BEHAV_RUNTIME/numBlocks) / minTrialTime);
    
    trialBlocks = cell(numBlocks,1);
    trialBlocks{1} = buildTrials_blocked(taskStruct, maxNumTrials, taskStruct.STATE_HIGH, taskStruct.REWARD_LOW);
    trialBlocks{2} = buildTrials_blocked(taskStruct, maxNumTrials, taskStruct.STATE_LOW, taskStruct.REWARD_LOW);
    trialBlocks{3} = buildTrials_blocked(taskStruct, maxNumTrials, taskStruct.STATE_HIGH, taskStruct.REWARD_HIGH);
    trialBlocks{4} = buildTrials_blocked(taskStruct, maxNumTrials, taskStruct.STATE_LOW, taskStruct.REWARD_HIGH);
    % randomly shuffle
    trialBlocks([1 2 3 4]) = trialBlocks(randsample([1 2 3 4], 4, false));
    % repeat blocks with new shuffling
    trialBlocks{5} = buildTrials_blocked(taskStruct, maxNumTrials, taskStruct.STATE_HIGH, taskStruct.REWARD_LOW);
    trialBlocks{6} = buildTrials_blocked(taskStruct, maxNumTrials, taskStruct.STATE_LOW, taskStruct.REWARD_LOW);
    trialBlocks{7} = buildTrials_blocked(taskStruct, maxNumTrials, taskStruct.STATE_HIGH, taskStruct.REWARD_HIGH);
    trialBlocks{8} = buildTrials_blocked(taskStruct, maxNumTrials, taskStruct.STATE_LOW, taskStruct.REWARD_HIGH);
    trialBlocks([5 6 7 8]) = trialBlocks(randsample([5 6 7 8], 4, false));
    
    % wait for prompt from technician to start waiting for pulse signal
    waitForTechPrompt(ioStruct);
    
    % wait for user to initiate
    Screen(ioStruct.wPtr, 'Flip');
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Arial');
    DrawFormattedText(ioStruct.wPtr, ([1500 1495 1510 47 1497 32 1506 1500 32 1502 1511 1513 32 1492 1512 1493 1493 1495 32 1499 1513 1488 1514 47 1492 32 1502 1493 1499 1504 47 1492 32 1500 1492 1514 1495 1497 1500 46]), 'center', 'center'); % changed to Hebrew by Rani
    %DrawFormattedText(ioStruct.wPtr, 'Press the spacebar when you''re ready to start.', 'center', 'center');
    RestrictKeysForKbCheck( KbName('space') );
    Screen(ioStruct.wPtr, 'Flip');
    KbWait(-3, 2);
    RestrictKeysForKbCheck([]);
    
    % wait for initial pulse from scanner
    taskStruct.startTime = GetSecs();
    
    % loop through timed blocks
    %
    % time duration of each block
    blockTime = taskStruct.MAX_BEHAV_RUNTIME/numBlocks;
    % will hold all completed task trials
    taskStruct.trials = [];
    
    % initialize the break timer
    lastBreakTime = GetSecs();
    % loop through all blocks
    for bI = 1 : length(trialBlocks)
        % current trial in the current block
        tI = 1;

        % loop through the block timer
        blockEndTime = (taskStruct.startTime + (bI*blockTime));
        while GetSecs() < blockEndTime
            % run a trial
            trialBlocks{bI}(tI,:) = showTrial(taskStruct, ioStruct, trialBlocks{bI}(tI,:));
            taskStruct.trials = vertcat(taskStruct.trials, trialBlocks{bI}(tI,:));
            saveTaskData(taskStruct, ioStruct)
            % update the trial count for the total experiment
            tI = tI + 1;
            
            % should we give a short break?
            if GetSecs() > lastBreakTime + ioStruct.BREAK_ITI
                waitForBreak(ioStruct);
                lastBreakTime = GetSecs();
            end
        end % while still in current block        
    end % while we still have time in the scanner
    
    taskStruct.endTime = GetSecs();
    % save data
    saveTaskData(taskStruct, ioStruct)
    
    % accumulate the total number of points earned
    totalPoints = round(nansum(taskStruct.trials.outcomeMag));
    % finish game
    Screen(ioStruct.wPtr, 'Flip');
    % show inter-block information
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Arial');
    DrawFormattedText(ioStruct.wPtr, ([1505 1497 1497 1502 1514 46 10 10 1492 1512 1493 1493 1495 1514 32 1505 1499 1493 1501 32 1513 1500 32 double(num2str(totalPoints)) 32 1504 1511 1493 1491 1493 1514 46 10 10 1511 1512 1488 47 1497 32 1500 1504 1505 1497 1497 1504 47 1497 1514 32 1489 1489 1511 1513 1492 46]), 'center', 'center'); % changed to Hebrew by Rani
    %DrawFormattedText(ioStruct.wPtr, ['You''re done.\n\n You earned a total of ' num2str(totalPoints) ' points.\n\n Please wait for the experimenter.'], 'center', 'center');
    % show prompt
    Screen(ioStruct.wPtr, 'Flip');

    RestrictKeysForKbCheck( ioStruct.respKey_Quit );
    [~, keyCode] = KbWait(-3,2);

    RestrictKeysForKbCheck( [] );
    ListenChar(1); ShowCursor();
    sca; 
end

% waits for the initial key-code as initial pulse from scanner
function secs = waitForBreak(ioStruct)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    % wait for the scanner to send the initial pulse signal
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Arial');
    
    % start the task start count-down
    for tI = ioStruct.BREAK_DURATION:-1:1
        DrawFormattedText(ioStruct.wPtr, [1494 1502 1503 32 1500 1492 1508 1505 1511 1492 32 1511 1510 1512 1492 46 10 32 1492 1502 1513 1495 1511 32 1497 1514 1495 1497 1500 32 1513 1493 1489 32 1489 1506 1493 1491 10 10 double(num2str(tI))], 'center', 'center');
        %DrawFormattedText(ioStruct.wPtr, ['Time for a short break.\n The game will start again in\n\n' num2str(tI)], 'center', 'center');
        Screen(ioStruct.wPtr, 'Flip');
        WaitSecs(1);
    end
end

% wait for experimentor input to prompt wait for scanner pulse
function secs = waitForTechPrompt(ioStruct)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Arial');
    DrawFormattedText(ioStruct.wPtr, ([1502 1502 1514 1497 1503 32 1513 1492 1504 1505 1497 1497 1504 47 1497 1514 32 1497 1505 1502 1504 1493 32 1513 1504 1497 1514 1503 32 1500 1492 1514 1495 1497 1500 46]), 'center', 'center');
    %DrawFormattedText(ioStruct.wPtr, 'Waiting for technician to mark ready status.', 'center', 'center');
    RestrictKeysForKbCheck( ioStruct.respKey_Proceed );
    Screen(ioStruct.wPtr, 'Flip');
    secs = KbWait(-3,2);
    RestrictKeysForKbCheck([]);
end

function [] = saveTaskData(taskStruct, ioStruct)
    % save data and clean up
    save(fullfile(taskStruct.outputFolder, taskStruct.fileName), 'taskStruct', 'ioStruct');
end