function ioStruct = initIOStruct()
    % hide input to prevent participant from over-writing into the script
    HideCursor(); ListenChar(2);
    Screen('Preference', 'SkipSyncTests', 1);
    KbName('UnifyKeyNames');
%     Screen('Preference', 'ConserveVRAM', 64);
    
    % set up the screen
    ioStruct = struct();
    ioStruct.bgColor = [60 60 60];
    ioStruct.textColor = [200 200 200];
    debugWinSize = [0,0,1000,800];
    fullWinSize = [];
    % run full-screen task
    % ADDED BY RANI - Specify a screen:
    screenNumber = max(Screen('Screens'));
    % EDITED BY RANI - Specify a screen:
    Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
    try
        Screen('Preference', 'SkipSyncTests', 0);
        [ioStruct.wPtr, ioStruct.wPtrRect] = Screen('OpenWindow', screenNumber, ioStruct.bgColor, fullWinSize);        
    catch
        WaitSecs(2);
        Screen('Preference', 'SkipSyncTests', 1); % we are not interested in precise timing
        Screen('Preference', 'VisualDebuglevel', 0);
        [ioStruct.wPtr, ioStruct.wPtrRect] = Screen('OpenWindow', screenNumber, ioStruct.bgColor, fullWinSize);
        Screen('Preference', 'VisualDebuglevel', 3);
    end

    % activate for alpha blending
    Screen('BlendFunction', ioStruct.wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Measure the vertical refresh rate of the monitor
    ioStruct.centerX = round(ioStruct.wPtrRect(3)/2);
    ioStruct.centerY = round(ioStruct.wPtrRect(4)/2);
    
    % show loading prompt
    Screen('TextFont', ioStruct.wPtr, 'Arial');
    % show the loading screen
    Screen('TextSize', ioStruct.wPtr, 45);
    Screen('TextColor', ioStruct.wPtr, ioStruct.textColor);
    DrawFormattedText(ioStruct.wPtr, ([1496 1493 1506 1503 46 46 46]), 'center', 'center', [], 70, false, false, 1.1); % changed to Hebrew by Rani
    % DrawFormattedText(ioStruct.wPtr, 'Loading...', 'center', 'center', [], 70, false, false, 1.1);
    Screen(ioStruct.wPtr, 'Flip');
    
    % stimulus durations
    ioStruct.SLOW = -1;
    ioStruct.MAX_RT = 2;
    ioStruct.BREAK_ITI = 5*60;
    ioStruct.BREAK_DURATION = 15;
    ioStruct.FIX_DURATION = 0.5;
    ioStruct.CHOICE_FB_DURATION = 1;
    ioStruct.REW_BIN_DURATION = 0;
    ioStruct.REW_MAG_DURATION = 1.5;
    ioStruct.BLOCK_START_WAIT = 3;
    ioStruct.BLOCK_END_WAIT = 4;
    
    % response keys
    ioStruct.LEFT = 1;
    ioStruct.RIGHT = 2;
    ioStruct.respKey_1 = [ KbName('D'),  KbName('1'), KbName('1!') ];
    ioStruct.respKey_2 = [ KbName('K'),  KbName('4'), KbName('4$') ];
    
    % task control keys
    ioStruct.respKey_Quit = KbName('Q');
    ioStruct.respKeyName_Quit = 'Q';
    ioStruct.respKey_Proceed = KbName('P');
    ioStruct.respKeyName_Proceed = 'P';
    
    % pulse signal
    ioStruct.pulseKey = [ KbName('5') KbName('5%') ];
    
    %%%%%%%%%%%%%%%%%%%%%
    % 1st stage choice option rects
    
    % space-ships
    ioStruct.rectButton = nan(2,4);
    width = 200; height = 200;
    rect = [0, 0, width, height];
    gap = 100;
    % define left ship
    leftX = ioStruct.centerX - gap - width;
    topY = ioStruct.centerY - round(height/2);
    ioStruct.rectButton(ioStruct.LEFT,:) = rect + [leftX, topY, leftX, topY];
    % define the right ship
    leftX = ioStruct.centerX + gap;
    ioStruct.rectButton(ioStruct.RIGHT,:) = rect + [leftX, topY, leftX, topY];
    
    % take-off count-down
    width = 50; height = 130;
    rect = [0, 0, width, height];
    leftX = ioStruct.centerX - round(width/2);
    topY = ioStruct.centerY - round(height/2);
    ioStruct.rectCountdown_Ship = rect + [leftX, topY, leftX, topY];
    
    % reward magnitude
    width = 50; height = 50;
    rect = [0, 0, width, height];
    leftX = ioStruct.centerX - round(width/2);
    topY = ioStruct.rectCountdown_Ship(2) - height - 20;
    ioStruct.rectRewMag = rect + [leftX, topY, leftX, topY];
    
    % 2nd stage state rect
    width = 800; height = 600;
    rect = [0, 0, width, height];
    % move to the center of the screen
    leftX = ioStruct.centerX - round(width/2);
    topY = ioStruct.centerY - round(height/2);
    ioStruct.rectState2 = rect + [leftX, topY, leftX, topY];
    
    % outcome mining bucket
    width = 250; height = 250;
    rect = [0, 0, width, height];
    % move to the center of the screen
    leftX = ioStruct.centerX - round(width/2);
    topY = ioStruct.centerY - round(width/2);
    ioStruct.rectOutcome = rect + [leftX, topY, leftX, topY];
    
    % tram-arrival count-down
    width = 50; height = 150;
    rect = [0, 0, width, height];
    leftX = ioStruct.centerX - round(width/2);
    topY = ioStruct.centerY - round(height/2);
    ioStruct.rectCountdown_Tram = rect + [leftX, topY, leftX, topY];
    
    
    % outcome reward
    width = 125; height = 125;
    rect = [0, 0, width, height];
    % move to the center of the screen
    leftX = ioStruct.centerX - round(width/2);
    topY = ioStruct.rectOutcome(2) + (ioStruct.rectOutcome(4)-ioStruct.rectOutcome(2))/2 - round(height/2);
    ioStruct.rectReward = rect + [leftX, topY, leftX, topY];
    
    % second stage pad choices
    ioStruct.rectPadDoor = nan(2,4);
    width = 150; height = 150;
    rect = [0, 0, width, height];
    gap = 30;
    % left button
    leftX = ioStruct.rectOutcome(1) - width - gap;
    topY = ioStruct.centerY - round(height/2);
    ioStruct.rectPadDoor(1,:) = rect + [leftX, topY, leftX, topY];
    % right button
    leftX = ioStruct.rectOutcome(3) + gap;
    ioStruct.rectPadDoor(2,:) = rect + [leftX, topY, leftX, topY];
    
    
    % load the state stimuli (lunar surfaces)
    imageDir = fullfile('.', 'images');
    ioStruct.imgState(1) = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(imageDir, 'red-planet.png')));
    ioStruct.imgState(2) = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(imageDir, 'red-planet2.png')));
    ioStruct.imgState(3) = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(imageDir, 'green-planet2.jpg')));
    ioStruct.imgState(4) = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(imageDir, 'green-planet.jpg')));
    
    % spaceships
    [img, ~, alpha] = imread(fullfile(imageDir, 'yellowShip.png'));
    img(:,:,4) = alpha;
    ioStruct.spaceShip(1) = Screen('MakeTexture', ioStruct.wPtr, img);
    [img, ~, alpha] = imread(fullfile(imageDir, 'blueShip.png'));
    img(:,:,4) = alpha;
    ioStruct.spaceShip(2) = Screen('MakeTexture', ioStruct.wPtr, img);
    % ships prepped for takeoff
    [img, ~, alpha] = imread(fullfile(imageDir, 'yellowShip_takeOff.png'));
    img(:,:,4) = alpha;
    ioStruct.spaceShipSelect(1) = Screen('MakeTexture', ioStruct.wPtr, img);
    [img, ~, alpha] = imread(fullfile(imageDir, 'blueShip_takeOff.png'));
    img(:,:,4) = alpha;
    ioStruct.spaceShipSelect(2) = Screen('MakeTexture', ioStruct.wPtr, img);
    
    % take-off countdown
    ioStruct.imgCountdown_4 = nan(5,1);
    for cI = 1 : length(ioStruct.imgCountdown_4)
        ioStruct.imgCountdown_4(cI) = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(imageDir, ['countdown_4_' num2str(cI) '.png'])));
    end
    
    % load the outcome images
    ioStruct.imgBucket = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(imageDir, 'spaceBucket.png')));
    ioStruct.imgGem = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(imageDir, 'spaceGem3.png')));
    ioStruct.imgRubble = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(imageDir, 'spaceBoulder.png')));
end