function [] = run_SpaceMarket_Practice(subID)
    % initialize task variables
    taskStruct = initTaskStruct();
    
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
    taskStruct.fileName = [taskStruct.subID '_Sub_session_' num2str(taskStruct.sessionID) '_prac_' datestr(now, 'mm-dd-yyyy_HH-MM-SS')];
    
    % initialize the IO for the task
    ioStruct = initIOStruct();
    % build a set of trials
    taskStruct.trials = buildTrials_blocked(taskStruct, 30, taskStruct.STATE_HIGH, taskStruct.REWARD_HIGH);
    
    % wait for initialization from experimenter
    Screen(ioStruct.wPtr, 'Flip');
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Arial');
    %DrawFormattedText(ioStruct.wPtr, 'Waiting for technician to mark ready status.', 'center', 'center');
    DrawFormattedText(ioStruct.wPtr, ([1502 1502 1514 1497 1503 32 1513 1492 1504 1505 1497 1497 1504 47 1497 1514 32 1497 1505 1502 1504 1493 32 1513 1504 1497 1514 1503 32 1500 1492 1514 1495 1497 1500 46]), 'center', 'center'); % changed to Hebrew by Rani
    RestrictKeysForKbCheck( ioStruct.respKey_Proceed );
    Screen(ioStruct.wPtr, 'Flip');
    KbWait(-3, 2);
    RestrictKeysForKbCheck([]);
    
    % wait for user to initiate
    Screen(ioStruct.wPtr, 'Flip');
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Arial');
    DrawFormattedText(ioStruct.wPtr, ([1504 1510 1500 47 1497 32 1489 1489 1511 1513 1492 32 1488 1514 32 1492 1494 1502 1503 32 1492 1494 1492 32 1499 1491 1497 32 1500 1489 1495 1493 1503 32 1493 1500 1500 1502 1493 1491 32 1488 1514 32 1492 1502 1513 1495 1511 46 10 10 1500 1495 1510 47 1497 32 1506 1500 32 1502 1511 1513 32 1492 1512 1493 1493 1495 32 1499 1513 1488 1514 47 1492 32 1502 1493 1499 1504 47 1492 32 1500 1492 1514 1495 1497 1500 46]), 'center', 'center'); % changed to Hebrew by Rani
    %DrawFormattedText(ioStruct.wPtr, 'Please use this time to explore and learn about the game.\n\nPress the spacebar when you''re ready to start.', 'center', 'center');
    RestrictKeysForKbCheck( KbName('space') );
    Screen(ioStruct.wPtr, 'Flip');
    KbWait(-3, 2);
    RestrictKeysForKbCheck([]);
    
    % track start time
    taskStruct.startTime = GetSecs();
    
    % start the task start count-down
    for tI = 5:-1:1
        DrawFormattedText(ioStruct.wPtr, [([1492 1514 1512 1490 1493 1500 32 1497 1514 1495 1497 1500 32 1489 1506 1493 1491]) 10 10 double(num2str(tI))], 'center', 'center'); % changed to Hebrew by Rani
        %DrawFormattedText(ioStruct.wPtr, ['Practice will start in\n\n' num2str(tI)], 'center', 'center');
        Screen(ioStruct.wPtr, 'Flip');
        WaitSecs(1);
    end
    
    % loop through all trials
    for tI = 1 : size(taskStruct.trials, 1)
        taskStruct.trials(tI,:) = showTrial(taskStruct, ioStruct, taskStruct.trials(tI,:));
        saveTaskData(taskStruct, ioStruct);
    end % for each trial
    taskStruct.endTime = GetSecs();
    
    % finish game
    Screen(ioStruct.wPtr, 'Flip');
    % show inter-block information
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Arial');
    DrawFormattedText(ioStruct.wPtr, ([1506 1491 1499 1504 47 1497 32 1489 1489 1511 1513 1492 32 1488 1514 32 1492 1504 1505 1497 1497 1504 47 1497 1514 32 1513 1505 1497 1497 1502 1514 32 1488 1514 32 1492 1514 1512 1490 1493 1500 46]), 'center', 'center');  % changed to Hebrew by Rani
    %DrawFormattedText(ioStruct.wPtr, 'Please let the experimenter know you''re finished practicing.', 'center', 'center');
    % show prompt
    Screen(ioStruct.wPtr, 'Flip');

    RestrictKeysForKbCheck( ioStruct.respKey_Quit );
    KbWait(-3,2);

    RestrictKeysForKbCheck( [] );
    ListenChar(1); ShowCursor();
    sca; 
end

function [] = saveTaskData(taskStruct, ioStruct)
    % save data and clean up
    save(fullfile(taskStruct.outputFolder, taskStruct.fileName), 'taskStruct', 'ioStruct');
end