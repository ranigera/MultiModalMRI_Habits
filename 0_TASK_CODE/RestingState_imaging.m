function var = RestingState_imaging(var, run, use_eyetracker)

% run:
% 1 = before task (on the first day).
% 2 = after task completed (on the first or third day - depends on the group).
% var:
% The task main variable.
% use_eyetracker:
% 1 = default. use eye tracker.
% 2 = default. no eye tracker.
% * 'RS' is the task code for the use of the
% initializeEyeTracker function.

% add the function folder to the path just for this session
path(path, 'functions');

%clear all
rng shuffle
% relies any disables/restrictions of keys.
DisableKeysForKbCheck([]);
RestrictKeysForKbCheck([]);
% =========================================================================
%% Parameters:
% =========================================================================
if ~exist('use_eyetracker', 'var')
    use_eyetracker = 1;
end

% screen parameters
backgroundColor = [180 180 180];
pixelSize = 32;

% Instructions:
%---------------------------------
% Title: "Resting with eyes open"
instructionsTitle = [1502 1504 1493 1495 1492 32 1489 1506 1497 1504 1497 1497 1501 32 1508 1511 1493 1495 1493 1514];
% content: "Resting with eyes open"
instructionsContent = [10 10 10 1489 1495 1500 1511 32 1494 1492 32 1497 1493 1508 1497 1506 32 1502 1505 1498 32 1512 1497 1511 32 1493 1489 1502 1512 1499 1494 1493 32 1504 1511 1493 1491 1492 32 1489 1492 32 1504 1497 1514 1503 32 1500 1492 1514 1502 1511 1491 10 1500 1502 1513 1498 32 49 48 32 1491 1511 1493 1514 46 10 10 1492 1504 1498 32 1502 1514 1489 1511 1513 47 1514 32 1500 1492 1513 1488 1512 32 1506 1501 32 1506 1497 1504 1497 1497 1501 32 1508 1511 1493 1495 1493 1514 46 10 10 10 10 10 10 1500 1495 1510 47 1497 32 1506 1500 32 1488 1495 1491 32 1492 1502 1511 1513 1497 1501 32 1499 1491 1497 32 1500 1492 1514 1495 1497 1500];
% immediately starting (when the code waits for trigger)
instructionsStartingSoon = [1502 1497 1491 32 1502 1514 1495 1497 1500 1497 1501 46 46 46];
% "Thank you!"
instructionsThankYou = [1514 1493 1491 1492 33];

% =========================================================================
%% Get input args and check if input is ok
% =========================================================================
clc
if ~isfield(var, 'sub_ID') % if the subID was not already entered and thus exist in the workspace.
    var.sub_ID = input('***input*** SUBJECT NUMBER: ');
else
    disp(['-- SUBJECT NUMBER: ' num2str(var.sub_ID) ' --'])
end
% check validity of SUBJECT number:
while isempty(var.sub_ID) || ~isa(var.sub_ID,'double') || var.sub_ID <= 100 || var.sub_ID >= 300 || var.sub_ID == 200
    var.sub_ID = input('SUBJECT NUMBER must be 101-199 or 201-299. SUBJECT NUMBER: ');
end
% get training according to subject number:
if var.sub_ID > 100 && var.sub_ID < 200
    var.training = 1;
elseif var.sub_ID > 200 && var.sub_ID < 300
    var.training = 3;
end

fprintf(['\n\nsubjectID is: ' num2str(var.sub_ID) '\n']);
disp(['resting state run: ' num2str(run)]);
disp(['use eyetracker is: ' num2str(use_eyetracker)]);
fprintf('\n')

GoOn=input('Press ENTER to continue or type ''exit'' to quit: ' , 's');
while ~isempty(GoOn)
    if strcmp(GoOn, 'exit')
        disp('please check you numbers and start over')
        return
    else
        GoOn=input('Press ENTER to continue or type ''exit'' to quit: ' , 's');
    end
end

%==========================================================
%% 'INITIALIZE Screen variables'
%==========================================================
for i = 1:2 %try with eye tracker and give a chance if it doesn't work to run it without it.
    HideCursor;
    screenNumber = max(Screen('Screens')); % check if there are one or two screens and use the second screen when if there is one
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'VisualDebuglevel', 0); %No PTB intro screen
    % [var.w] = Screen('OpenWindow',screenNumber,[],[0 0 640 480],pixelSize);% %debugging screensize
    [var.w] = Screen('OpenWindow',screenNumber, backgroundColor,[],pixelSize);
    Screen('Preference', 'VisualDebuglevel', 3);
    
    % Set up screen positions for stimuli
    [~, wHeight] = Screen('WindowSize', var.w);
    
    % % Set the colors
    black = BlackIndex(var.w); % Should equal 0.
    
    Screen('FillRect', var.w, backgroundColor);  % NB: only need to do this once!
    Screen('Flip', var.w);
    
    %fixation
    frameRect = [0 0 640 480];
    fixation = Screen(var.w,'OpenOffscreenWindow', backgroundColor, frameRect);
    Screen(fixation, 'FillOval', black, CenterRect([0 0  16  16], frameRect));
    
    %-----------------------------------------------------------------
    % Initializing eye tracking system %
    %-----------------------------------------------------------------
    try
        [edfFile, el] = initializeEyeTracker(use_eyetracker, var, 'RS', run);
        % Screen('FillRect', var.w, [180 180 180]);
        break
    catch
        Screen('CloseAll');
        ShowCursor;
        fclose('all');
        disp('*** EYE TRACKER was not loaded successfully ***')
        decision = input('Do you want to continue WITHOUT EYE TRACKER (y/[n])?','s');
        if strcmp(decision,'y')
            use_eyetracker = 0;
        else
            error('Running ABORTED!')
        end
    end
end

% make sure no key is pressed before beginning a task:
while KbCheck(-3,2)
end

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------
Screen('TextFont',var.w, 'Arial');
Screen('TextStyle', var.w, 1);
Screen('TextSize', var.w, 60);
DrawFormattedText(var.w, instructionsTitle, 'center', wHeight/5, [0 0 0], 60);
Screen('TextStyle', var.w, 0);
Screen('TextSize', var.w, 40);
DrawFormattedText(var.w, instructionsContent, 'center', 'center', [0 0 0], 60);
Screen(var.w, 'Flip');

noresp = 1;
while noresp
    [keyIsDown] = KbCheck(-1); % deviceNumber=keyboard
    if keyIsDown && noresp
        noresp = 0;
    end
end

Screen('TextSize', var.w, 60);
DrawFormattedText(var.w, instructionsStartingSoon, 'center', 'center', [0 0 0], 60);
Screen('Flip',var.w);

escapeKey = KbName('t');
while 1
    [keyIsDown,~,keyCode] = KbCheck(-1);
    if keyIsDown && keyCode(escapeKey)
        break;
    end
end
DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected

tic

% start recording eye position
%-----------------------------
if use_eyetracker
    % start recording eye position
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);
    Eyelink('StartRecording');
    WaitSecs(0.05);
    Eyelink('Message',['SYNCTIME at run start:',num2str(GetSecs)]); % mark start time in file
end

%---------------------------------------------------------------
%% 'Run 10 min of gray screen with a fixation cross'
%---------------------------------------------------------------
Screen('FillRect', var.w, backgroundColor);  % NB: only need to do this once!
Screen('DrawTexture', var.w, fixation);
Screen(var.w,'Flip');

tic
WaitSecs(600); % 10 min
toc

Screen('TextStyle', var.w, 1);
Screen('TextSize',var.w, 40);
DrawFormattedText(var.w, instructionsThankYou, 'center', 'center', [0 0 0], 60);
Screen(var.w,'Flip');
WaitSecs(3);

ShowCursor;
Screen('CloseAll');
DisableKeysForKbCheck([]);

if use_eyetracker
    %---------------------------------------------------------------
    %%   Finishing eye tracking system %
    %---------------------------------------------------------------
    
    % STEP 7
    %---------------------------
    % finish up: stop recording eye-movements,
    % close graphics window, close data file and shut down tracker
    Eyelink('StopRecording');
    Eyelink('Message',['SYNCTIME at run end:',num2str(GetSecs)]); % mark end time in file
    WaitSecs(.1);
    Eyelink('CloseFile');
    
    % assemble file name
    time = [datestr(now,'dd-mmm-yy_') datestr(now,'HH') 'h' datestr(now,'MM') 'm'];
    fileNameToSave = strcat('data/eyeTrackerData/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_task-HAB_MRI_', num2str(var.training),'day_stage-RS_run-',num2str(run,'%02.0f'),'_', time, '.edf');
    
    % download data file
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile', edfFile, fileNameToSave);
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found as ''%s''\n', edfFile, fileNameToSave);
        end
    catch rdf
        fprintf('Problem receiving data file ''%s''\n', edfFile );
        rdf;
    end
    
    [~,tmp] = system(['./functions/edf2asc ',fileNameToSave]);
    converted_ok = ~isempty(strfind(tmp,'successfully'));
    if ~converted_ok
        disp('Coversion of EDF file to ASCII didn''t go well!\n');
    end
    
    Eyelink('ShutDown');
end
end
