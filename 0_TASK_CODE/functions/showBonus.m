function showBonus(var, data)
% depict bonus slide for the devaluation procedure

% Get the total earnings to present with the bonus slide:
won_sweet = sum(data.training.reward(data.training.condition == 1))/2;
won_salty = sum(data.training.reward(data.training.condition == 2))/2;
%message = ['This session you won: ' num2str(won_sweet) ' ' var.sweetLabel ' and ' num2str(won_salty) ' ' var.saltyLabel ' ' '(Please inform the investigator).' ];
messageWonTotal = [1505 1498 32 1492 1499 1500 32 1504 1510 1489 1512 1493 58 32 double(num2str(won_sweet)) 32 var.sweetLabelHebrew 32 1493 45 double(num2str(won_salty)) 32 var.saltyLabelHebrew 46];

% get the picture and text
if var.devalued == 1 % target for devaluation will be sweet
    target_pict = var.sweetImageBulk;
    %message     = ['Bonus!  All you can eat ' var.sweetLabel];
    message      = [10 45 32 1489 1493 1504 1493 1505 33 32 45 10 10 1488 1499 1493 1500 47 1488 1499 1500 1497 32 var.sweetLabelHebrew 32 1499 1508 1497 32 1497 1499 1493 1500 1514 1498 33];
elseif var.devalued == 2 % target for devaluation will be savory
    target_pict  = var.saltyImageBulk;
    %message     = ['Bonus!  All you can eat ' var.saltyLabel];
    message      = [10 45 32 1489 1493 1504 1493 1505 33 32 45 10 10 1488 1499 1493 1500 47 1488 1499 1500 1497 32 var.saltyLabelHebrew 32 1499 1508 1497 32 1497 1499 1493 1500 1514 1498 33];
end

sizeBulkImage = round(var.FRACTALdim * 0.74);
% define position of the picture
baseRect           = [0 0 sizeBulkImage sizeBulkImage];% Make a base Rect
positionPicture    = CenterRectOnPointd(baseRect, var.xCenter, round(var.yCenter*1.31));

% format text
Screen('TextFont', var.w, 'Arial');
Screen('TextSize', var.w, var.scaledSize);
Screen('TextStyle', var.w, 1);

% prepare the bonus screen
target_text  = Screen('MakeTexture',var.w, target_pict);
Screen('DrawTexture', var.w, target_text ,[], positionPicture );
DrawFormattedText(var.w, messageWonTotal , 'center', var.yUpper, [0 0 0], 60);
DrawFormattedText(var.w, message , 'center', var.yUpperLow, [0 0 0], 60);

% show the screen
Screen('Flip',var.w, 0, 1);

% add to the message to press on a button to continue
WaitSecs(3);
pressToContinueTXT = [10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 1500 1495 1510 47 1497 32 1506 1500 32 1502 1511 1513 32 1499 1500 1513 1492 1493 32 1499 1491 1497 32 1500 1492 1502 1513 1497 1498];
DrawFormattedText(var.w, pressToContinueTXT, 'center', 'center', [0 0 0], 60);
Screen(var.w, 'Flip');

% wait for a button press
WaitSecs(1);
while 1
    down = KbCheck(-3,2);
    if down
        break
    end
end

end