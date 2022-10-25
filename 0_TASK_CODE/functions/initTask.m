function [var,data]= initTask(var)

%% CREATE RESULT FILE FOR THE SESSION
if isfield(var, 'runs') % as an indicator of running in the MRI code
    var.resultFile = strcat('data/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'.mat');
else
    var.resultFile = strcat('data/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'.mat');
end

% <<<read snacks if already were entered... >>>
% -------------------------------------------------------------------------
% Create the name of file of the previous session in case there was one.
if isfield(var, 'runs') % as an indicator of running in the MRI code
    NamePrevious  = (strcat('data/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session-1,'%02.0f'),'.mat'));
else
    NamePrevious  = (strcat('data/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_', num2str(var.training), 'day_session-',num2str(var.session-1,'%02.0f'),'.mat'));
end

if exist(var.resultFile,'file')
    load(var.resultFile, 'data')
elseif exist(NamePrevious,'file')
    load(NamePrevious, 'data')
end
if exist(var.resultFile,'file') || exist(NamePrevious,'file')
    snackList = {'M&Ms' 'Click' 'Skittles' 'Cashews' 'Doritos' 'Tapuchips'};
    var.sweet = find(strcmp(data.sweetID, snackList));
    var.salty = find(strcmp(data.saltyID, snackList));
    if exist(NamePrevious,'file') && ~exist(var.resultFile,'file')
        clear data
    end
elseif isfield(var, 'runs') && isfield(var, 'sweet') && isfield(var, 'salty') % i.e., it's not the first time initTask runs but there is still no data file (after fail of the eyetracker).
    % do nothing. the sweet and salty were already recorded.
else
    % enter the snack the participant prefers and check input
    var.sweet = input('***input*** SWEET REWARD (1=M&M, 2=click, 3=skittles): ');
    while isempty(var.sweet) || ~ismember(var.sweet,1:3)
        var.sweet = input('*** WRONG input, enter gain *** SWEET REWARD (1=M&M, 2=click, 3=skittles): ');
    end
    var.salty = input('***input*** SALTY REWARD (4=cashew, 5=doritos, 6=tapuchips): ');
    while isempty(var.salty) || ~ismember(var.salty,4:6)
        var.salty = input('*** WRONG input, enter gain *** SALTY REWARD (4=cashew, 5=doritos, 6=tapuchips): ');
    end
end

%**************************************************************************

PsychDefaultSetup(1);% Here we call some default settings for setting up PTB; A ???featureLevel??? of 1 will execute 'AssertOpenGL' and KbName(???UnifyKeyNames???) to provide a consistent mapping of keyCodes to key names on all operating systems.
KbCheck; WaitSecs(0.1); GetSecs; FlushEvents; % clean the keyboard memory Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure they are loaded and ready when we need them - without delays
rng('shuffle');% reset randperm to avoid the same seq

% Prioritizing the script execution over other computer operations (*probabely best for precision)
whichScreen = max(Screen('Screens'));
maxPriorityLevel = MaxPriority(whichScreen);
Priority(maxPriorityLevel);

%**************************************************************************
% OPEN PST
screenNumber = max(Screen('Screens')); % check if there are one or two screens and use the second screen when if there is one
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen

try
    Screen('Preference', 'SkipSyncTests', 0);
    [var.w, var.rect] = Screen('OpenWindow',screenNumber, [180 180 180]);
    %[var.w, var.rect] = Screen('OpenWindow',screenNumber, [180 180 180],[0 0 640 480]);% %debugging screensize    
catch
    WaitSecs(2);
    Screen('Preference', 'SkipSyncTests', 1); % we are not interested in precise timing
    Screen('Preference', 'VisualDebuglevel', 0);
    [var.w, var.rect] = Screen('OpenWindow',screenNumber, [180 180 180]);
    Screen('Preference', 'VisualDebuglevel', 3);
end

% Set blend function for alpha blending (for the png iamges)
Screen('BlendFunction', var.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

HideCursor;
%**************************************************************************
% SET TASK PARAMETERS
%**************************************************************************

% button code
if isfield(var, 'runs') % as an indicator of running in the MRI code
    % for scanner
    var.leftKey        = KbName('b');
    var.centerLeftKey  = KbName('y');
    var.centerRightKey = KbName('g');
    var.rightKey       = KbName('r');
    var.pulseKeyCode   = KbName('t');
    var.mySafetyControl= KbName('q'); %for the experimenter
else
    % for behavior
    var.practiceSquare1Key = [ KbName('a'), KbName('a') ];
    var.practiceSquare2Key = [ KbName('s'), KbName('s') ];
    var.leftKey        = [ KbName('d'), KbName('d') ];
    var.centerLeftKey  = [ KbName('f'), KbName('f') ];
    var.centerRightKey = [ KbName('j'), KbName('J') ];
    var.rightKey       = [ KbName('k'), KbName('k') ];
    var.mycontrol      = KbName('space');
    var.mySafetyControl= KbName('q');
    var.pulseKeyCode   = KbName('space'); % to start each run
end

var.availableKeysInTask = zeros(256,1);
var.availableKeysInTask([var.leftKey, var.centerLeftKey, var.centerRightKey, var.rightKey]) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE POSITIONS

[var.screenXpixels, var.screenYpixels] = Screen('WindowSize', var.w);% Ge
[var.xCenter, var.yCenter] = RectCenter(var.rect);% Get the centre coordinate of the windo

ROIlt = 0.35; %from the left and from the top co-ordinates for left and top ROI
space = 0.10;

var.yUpperHigh = 0.10*var.screenYpixels;
var.yUpper     = 0.25*var.screenYpixels;
var.yUpperLow  = 0.40*var.screenYpixels;
var.yLower     = 0.75*var.screenYpixels;
var.yLowerLow  = 0.90*var.screenYpixels;

var.squareXpos = [var.screenXpixels * ROIlt var.screenXpixels * (ROIlt+1*space) var.screenXpixels * (ROIlt+2*space) var.screenXpixels * (ROIlt+3*space)]; % Define horizontal ROIs position (0.25 0.75 were the original settings)

var.square1 = var.screenXpixels * ROIlt;
var.square2 = var.screenXpixels * (ROIlt+1*space);
var.square3 = var.screenXpixels * (ROIlt+2*space);
var.square4 = var.screenXpixels * (ROIlt+3*space);

var.CUEdim      = RectHeight(var.rect)/16; % the pixel of the ROI are defined based on the screeen
var.FRACTALdim  = RectHeight(var.rect)/3; % the pixel of the ROI are defined based on the screeen
var.REWARDdim   = RectHeight(var.rect)/8; % pixels of reward display
var.ACTIONdim   = RectHeight(var.rect)/16; % pixels of instrumental action feedback display
var.allColors   = [250 250 250 250; 250 250 250 250; 0 0 0 0];% Set the colors of the ROI frames

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTERBALANCE STIMULUS-RESPONSE-OUTCOME
if exist(var.resultFile,'file')
    [var, data] = counterbalance(var, data);
else
    [var, data] = counterbalance(var);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NUMBER OF RUNS
%
% if var.training == 1 % instrumental action training
%     var.runs = 2;
% elseif var.training == 3 % habitual training
%     var.runs = 4;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULT TEXT STYLE
% scale text size to the screen used
textref = 40;
windowref_y = 1560; % we want something that correpond to a size of 30 on a screen with a y of 1560
var.scaledSize = round((textref * var.rect(4)) / windowref_y);

% set screen setting

Screen('TextFont', var.w, 'Arial');
Screen('TextSize', var.w, var.scaledSize);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD IMAGES OF SNACKS USED AS SWEET AND SALTY
[var] = uploadImages (var);
data.sweetID = var.sweetLabel;
data.saltyID = var.saltyLabel;

data.screen = var.rect;
data.SubDate = datestr(now, 24); % Use datestr to get the date in the format dd/mm/yyyy
if ~isfield(data, 'SubHour')
    data.SubHour = {datestr(now, 13)}; % Use datestr to get the time in the format hh:mm:ss
else
    data.SubHour(end+1)= {datestr(now, 13)}; % Use datestr to get the time in the format hh:mm:ss
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% More MRI parameters:
var.fixationDurationBeforeRun = 4;
var.fixationDurationAfterRun = 8;

end