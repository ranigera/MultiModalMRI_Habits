function trialSpec = showTrial(taskStruct, ioStruct, trialSpec)
    % only allow relevant keys
    RestrictKeysForKbCheck( [ioStruct.respKey_1, ioStruct.respKey_2] );
    
    % blank screen
    Screen('TextSize', ioStruct.wPtr, 40); Screen('TextColor', ioStruct.wPtr, ioStruct.textColor);
    DrawFormattedText(ioStruct.wPtr, '', 'center', 'center');
    [~, trialSpec.tStart] = Screen(ioStruct.wPtr, 'Flip', 0);
    
    % fixation
    Screen('TextSize', ioStruct.wPtr, 60); Screen('TextColor', ioStruct.wPtr, ioStruct.textColor);
    Screen('FillRect', ioStruct.wPtr, ioStruct.bgColor, ioStruct.rectOutcome);
    DrawFormattedText(ioStruct.wPtr, '+', 'center', 'center');
    [~, trialSpec.tFixOn] = Screen(ioStruct.wPtr, 'Flip', trialSpec.tStart + trialSpec.jitterITI, 1);
    
    % show the the left/right options
    Screen('DrawTexture', ioStruct.wPtr, ioStruct.spaceShip(1), [], ioStruct.rectButton(ioStruct.LEFT,:));
    Screen('DrawTexture', ioStruct.wPtr, ioStruct.spaceShip(2), [], ioStruct.rectButton(ioStruct.RIGHT,:));
    % remove fixation after all keys are released
    KbReleaseWait(-3);
    [~, trialSpec.tStim1On] = Screen(ioStruct.wPtr, 'Flip', trialSpec.tFixOn + ioStruct.FIX_DURATION, 1);
    
    % wait for response and store RT
    [trialSpec.tResp1, keyCode] = KbWait(-3, 2, GetSecs() + ioStruct.MAX_RT);
    trialSpec.RT1 = trialSpec.tResp1 - trialSpec.tStim1On;
    pressedKey = find(keyCode);
    
    % capture selected option
    if ismember(pressedKey, ioStruct.respKey_1)
        trialSpec.resp1 = ioStruct.LEFT;
    elseif ismember(pressedKey, ioStruct.respKey_2)
        trialSpec.resp1 = ioStruct.RIGHT;
    end
    
    % was a valid response captured
    if isempty(pressedKey)
        % no valid response - show too slow error
        trialSpec = showTooSlow(ioStruct, trialSpec);
        return;
    elseif length(pressedKey) > 1
        % mulitple responses made
        trialSpec = showMultiResp(ioStruct, trialSpec);
        return;
    end
    
    % track response features
    trialSpec.outcome1 = trialSpec.state2(trialSpec.resp1);
    
    % highlight the chosen ship
    Screen('DrawTexture', ioStruct.wPtr, ioStruct.spaceShipSelect(trialSpec.resp1), [], ioStruct.rectButton(trialSpec.resp1,:));    
    Screen(ioStruct.wPtr, 'Flip', 0, 1);
    WaitSecs(trialSpec.jitterResp1);
            
    % clear 1st stage choice after specified duration
    [~, trialSpec.tStim1Off] = Screen(ioStruct.wPtr, 'Flip');
    
    % show the 2nd state after choice jitter duration has elapsed
    Screen('DrawTexture', ioStruct.wPtr, ioStruct.imgState(trialSpec.state2(trialSpec.resp1)), [], ioStruct.rectState2);
    [~, trialSpec.tStim2On] = Screen(ioStruct.wPtr, 'Flip', 0, 1);
    
    % wait for response and store RT
    RestrictKeysForKbCheck( [ioStruct.respKey_1, ioStruct.respKey_2] );
    [trialSpec.tResp2, keyCode] = KbWait(-3, 2, GetSecs() + ioStruct.MAX_RT);
    trialSpec.RT2 = trialSpec.tResp2 - trialSpec.tStim2On;
    pressedKey = find(keyCode);
    
    % was a valid response captured
    if isempty(pressedKey)
        % no valid response - show too slow error
        trialSpec = showTooSlow(ioStruct, trialSpec);
        return;
    elseif length(pressedKey) > 1
        % mulitple responses made
        trialSpec = showMultiResp(ioStruct, trialSpec);
        return;
    end
    
    % capture selected option
    if ismember(pressedKey, ioStruct.respKey_1)
        trialSpec.resp2 = ioStruct.LEFT;
    elseif ismember(pressedKey, ioStruct.respKey_2)
        trialSpec.resp2 = ioStruct.RIGHT;
    end
    
    % show the reward box
    Screen('FillRect', ioStruct.wPtr, [153 153 153], ioStruct.rectOutcome);
    Screen(ioStruct.wPtr, 'Flip', 0, 1);
    WaitSecs(trialSpec.jitterFB);
        
    % compute outcome (win/loss/penalty) 
    trialSpec.outcomeBin = trialSpec.rewBinary(trialSpec.outcome1);
    trialSpec.outcomeMag = round(trialSpec.rewBinary(trialSpec.outcome1) * trialSpec.rewMagnitude * 100);
    if trialSpec.outcomeBin == 1
        rewardString = sprintf('%+2d', trialSpec.outcomeMag);
        rewImage = ioStruct.imgGem;
    else
        rewardString = '0';
        rewImage = ioStruct.imgRubble;
    end

    % show reward
    Screen('TextSize', ioStruct.wPtr, 100);
    Screen('FillRect', ioStruct.wPtr, ioStruct.bgColor, ioStruct.rectOutcome);
    Screen('DrawTexture', ioStruct.wPtr, rewImage, [], ioStruct.rectOutcome);
    [~, trialSpec.tFBOn] = Screen(ioStruct.wPtr, 'Flip', 0, 1);
    WaitSecs(ioStruct.REW_BIN_DURATION);

    % show the reward magnitude
    Screen('TextColor', ioStruct.wPtr, [255 255 255]);
    DrawFormattedText(ioStruct.wPtr, rewardString, 'center', 'center', [], [], [], [], [], [], ioStruct.rectReward );
    Screen(ioStruct.wPtr, 'Flip', 0, 0);
    WaitSecs(ioStruct.REW_MAG_DURATION);
    trialSpec.tFBOff = GetSecs();
end


function trialSpec = showTooSlow(ioStruct, trialSpec)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    % show error text
    slowText = ([1500 1488 1496 32 1502 1497 1491 1497 33 10 10 1489 1495 1512 47 1497 32 1514 1493 1498 32 double(num2str(ioStruct.MAX_RT)) 32 1513 1504 1497 1493 1514 32 1489 1489 1511 1513 1492]); % changed to Hebrew by Rani
    %slowText = ['Too Slow!\n\n Please make your choice within ' num2str(ioStruct.MAX_RT) ' seconds'];
    Screen('TextSize', ioStruct.wPtr, 30);
    Screen('TextColor', ioStruct.wPtr, [255 0 0]);
    Screen('TextFont', ioStruct.wPtr, 'Arial');
    DrawFormattedText(ioStruct.wPtr, slowText, 'center', 'center');
    % show feedback for prescribed time, then clear screen
    [~, trialSpec.tFBOn] = Screen(ioStruct.wPtr, 'Flip');
    [~, trialSpec.tFBOff] = Screen(ioStruct.wPtr, 'Flip', GetSecs() + 1.5);
end

function trialSpec = showMultiResp(ioStruct, trialSpec)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    % show error text
    slowText = ([1494 1493 1492 1493 32 1502 1505 1508 1512 32 1514 1490 1493 1489 1493 1514 33 10 10 1489 1495 1512 47 1497 32 1489 1488 1508 1513 1512 1493 1514 32 1488 1495 1514 32 1489 1500 1489 1491 32 1489 1489 1511 1513 1492]); % changed to Hebrew by Rani
    %slowText = 'Multiple responses detected!\n\n Please select only a single option';
    Screen('TextSize', ioStruct.wPtr, 30);
    Screen('TextColor', ioStruct.wPtr, [255 0 0]);
    Screen('TextFont', ioStruct.wPtr, 'Arial');
    DrawFormattedText(ioStruct.wPtr, slowText, 'center', 'center');
    % show feedback for prescribed time, then clear screen
    [~, trialSpec.tFBOn] = Screen(ioStruct.wPtr, 'Flip');
    [~, trialSpec.tFBOff] = Screen(ioStruct.wPtr, 'Flip', GetSecs() + 1.5);
end