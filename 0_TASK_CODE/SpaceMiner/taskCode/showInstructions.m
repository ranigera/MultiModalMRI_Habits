function [] = showInstructions(ioStruct, instrDir)
    instrFiles = dir(fullfile(instrDir, '*.png'));

    % load task instruction images
    ioStruct.instructions = nan(length(instrFiles),1);
    for iI = 1 : length(ioStruct.instructions)
        ioStruct.instructions(iI) = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(instrDir, instrFiles(iI).name )));
    end
    
    % define forward/back keys for each screne (default to arrow keys)
    backKeys = repmat({KbName('rightarrow')}, length(ioStruct.instructions), 1); % Arrow direction switched by Rani to match Hebrew writing direction.
    nextKeys = repmat({KbName('leftarrow')}, length(ioStruct.instructions), 1); % Arrow direction switched by Rani to match Hebrew writing direction.
    % define response keys the move them forward
    nextKeys{6} = ioStruct.respKey_1;
    nextKeys{8} = [ioStruct.respKey_1 ioStruct.respKey_2];
    nextKeys{19} = KbName('F');
    nextKeys{21} = KbName('F');
    nextKeys{23} = KbName('F');
    nextKeys{25} = KbName('J');
    nextKeys{27} = KbName('F');
    nextKeys{29} = KbName('J');
    nextKeys{end} = ioStruct.respKey_Quit;
    
    % initialize the instruction display
    instructionWidth = 960 * 1.5;
    instructionHeight = 540 * 1.5;
    leftX = ioStruct.centerX - round((instructionWidth/2));
    topY = ioStruct.centerY - round((instructionHeight/2));
    ioStruct.instructionRect = [leftX, topY, leftX+instructionWidth, topY+instructionHeight];
    
    % list of instructions to show
    instructions = 1:size(ioStruct.instructions);
    % init the current instruction
    currentInst = 1;

    % loop until done signal
    doneInst = false;
    while ~doneInst
        % show instructions
        Screen('DrawTexture', ioStruct.wPtr, ioStruct.instructions(currentInst), [], ioStruct.instructionRect );
        Screen(ioStruct.wPtr, 'Flip');
        
        % wait for navigation input
        RestrictKeysForKbCheck( [backKeys{currentInst}, nextKeys{currentInst} ] );
        [~, keyCode] = KbWait(-3, 2);

        % update the current instructin according to key press
        respKey = find(keyCode);
        if ismember( respKey, nextKeys{currentInst} ) && currentInst == instructions(end)
            doneInst = true;
        elseif ismember( respKey, backKeys{currentInst} )
            % move back
            currentInst = max(1, currentInst-1);
        elseif ismember( respKey, nextKeys{currentInst} )
            % move forward
            currentInst = min(length(instructions), currentInst+1);
        end
    end
    
    RestrictKeysForKbCheck([]);
end