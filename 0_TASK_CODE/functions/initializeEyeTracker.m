function [edfFile, el] = initializeEyeTracker(use_eyetracker, var, task, run)
%-----------------------------------------------------------------
% Initializing eye tracking system %
% Vars:
% use_eyetracker - boolean
% subID - subject number
% task -task code - no more then 2 letters!
% screenWindow - should be the window ('w' usually) returned when open a
% window with PTB.
%-----------------------------------------------------------------

% use_eyetracker=0; % set to 1/0 to turn on/off eyetracker functions
if use_eyetracker
    dummymode=0;
    
    % Set the colors
    backGrounColor = [180 180 180];
    black = BlackIndex(var.w);
    % Get screen size
    [wWidth, wHeight]=Screen('WindowSize', var.w);
    
    % STEP 2
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(var.w);
    % Disable key output to Matlab window:
    
    el.backgroundcolour = backGrounColor;
    el.backgroundcolour = backGrounColor;
    el.foregroundcolour = black;
    el.msgfontcolour    = black;
    el.imgtitlecolour   = black;
    el.calibrationtargetcolour = el.foregroundcolour;
    EyelinkUpdateDefaults(el);
    
    % STEP 3
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        %cleanup;  % cleanup function
        return;
    end
    
    [~,vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');
    
    % open file to record data to
    edfFile = ['sHIS' task num2str(run) '.edf'];
    if length(edfFile) > 12 % verify that the file has no more than 8 characters!!!
        error('The edf file has more than 8 characters!!! Abort running')
    end
    i = Eyelink('Openfile', edfFile);
    open_edf_attempt = 0;
    while i~=0 && open_edf_attempt<=5
        i = Eyelink('Openfile', edfFile);
        open_edf_attempt = open_edf_attempt + 1;
        fprintf('\nFailed to open EDF. Trying again. Attempt: %i\n',open_edf_attempt);
    end
    if i~=0
        error('Failed to open EDF too many times. Aborting script.');
    end
    
    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, wWidth-1, wHeight-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, wWidth-1, wHeight-1);
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    % set parser (conservative saccade thresholds)
    
    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
else
    edfFile = '';
    el = '';
    disp('*** EYE TRACKER was set up NOT TO be in use ***')
end

end

