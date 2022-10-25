function showWinnings(var, data, phase)

if ~strcmp(phase, 'extinction')
    won_sweet_last_run = sum(data.(phase).reward(data.(phase).run == data.(phase).run(end) & data.(phase).condition == 1))/2;
    won_salty_last_run = sum(data.(phase).reward(data.(phase).run == data.(phase).run(end) & data.(phase).condition == 2))/2;
    
    won_sweet = sum(data.(phase).reward(data.(phase).condition == 1))/2;
    won_salty = sum(data.(phase).reward(data.(phase).condition == 2))/2;
else % if it's extinction no snacks won:
    won_sweet_last_run = 0; won_salty_last_run = 0; won_sweet = 0; won_salty = 0;
end

%message = ['This session you won: ' num2str(won_sweet) ' ' var.sweetLabel ' and ' num2str(won_salty) ' ' var.saltyLabel ' ' '(Please inform the investigator).' ];
messageWonNow = [1492 1512 1493 1493 1495 1514 58 32 double(num2str(won_sweet_last_run)) 32 var.sweetLabelHebrew 32 1493 45 double(num2str(won_salty_last_run)) 32 var.saltyLabelHebrew 46];
%message = ['This session you won: ' num2str(won_sweet) ' ' var.sweetLabel ' and ' num2str(won_salty) ' ' var.saltyLabel ' ' '(Please inform the investigator).' ];
messageWonTotal = [1505 1498 32 1492 1499 1500 32 1504 1510 1489 1512 1493 58 32 double(num2str(won_sweet)) 32 var.sweetLabelHebrew 32 1493 45 double(num2str(won_salty)) 32 var.saltyLabelHebrew 46];

% Screen settings
Screen('TextFont', var.w, 'Arial');
Screen('TextSize', var.w, var.scaledSize);
Screen('TextStyle', var.w, 1);

% Print the winnings on the screen
DrawFormattedText(var.w, messageWonNow, 'center', 'center', [0 0 0], 60);
Screen(var.w, 'Flip');
WaitSecs(3);
DrawFormattedText(var.w, messageWonTotal, 'center', 'center', [0 0 0], 60);
Screen(var.w, 'Flip', 0, 1);
% add to the message to press on a button to continue
WaitSecs(3);
pressToContinueTXT = [10 10 10 10 10 10 10 1500 1495 1510 47 1497 32 1506 1500 32 1502 1511 1513 32 1499 1500 1513 1492 1493 32 1499 1491 1497 32 1500 1492 1502 1513 1497 1498];
DrawFormattedText(var.w, pressToContinueTXT, 'center', 'center', [0 0 0], 60);
Screen(var.w, 'Flip');

WaitSecs(1);
while 1
    down = KbCheck(-3,2);
    if down
        break
    end
end

% disp('winnings were presented');
% for the experimenter to know how many snacks to deliver:
disp(['won: ' num2str(won_sweet) ' ' var.sweetLabel ' and ' num2str(won_salty) ' ' var.saltyLabel])
fid = fopen('temporalFiles/tempWinnings.txt','w'); % write a temporal file with the winning in case the experimenter needs it.
fprintf(fid, ['SUBJECT - ' num2str(var.sub_ID) '\n\nWinnings:\n---------\n' num2str(won_sweet) ' ' var.sweetLabel '\n' num2str(won_salty) ' ' var.saltyLabel]);
fclose(fid);

end