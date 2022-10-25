function BR_MAIN()
% function BR_MAIN()
%__________________________________________________________________________
%--------------------------------------------------------------------------
%
% Free operant task with outcome devaluation procedure Tricomi et al., (2009)
% PTB 3.0.12 on matlab 2014b
%__________________________________________________________________________
%-------------------------------------------------------------------------
% last modified on AUGUST 2019 by Rani to fit an MRI experiment and
% integrating other tasks, for a Neuroimage registered report.
% modified on AUGUST 2017 by Eva

% session = different sessions collected on different days
% run = different runs on the same day
% button to answer: -d- -f- -j- -k- -left arrow- -right arrow- and -space-
% Press space to start practice runs
% -q- is the experimenter controller

% Rani - Mapped task codes to be saved to separated files through saveByStage
% function
% 'pr1' = pleasantness ratings at the beginning of the day
% 'hr1' = hunger ratings at the beginning of the day
% 'tc'  = test contingency (i.e., stimulus-outcome contingency test) at the end of the 1st day
% 'pr2' = pleasantness ratings following devaluation
% 'hr2' = hunger ratings following devaluation
% 'fr'  = fractals pleasantness ratings
% 'pr3' = pleasantness ratings after completing the task on the last day
% 'hr3' = hunger ratings after completing the task on the last day


% RELEVANT FOR THE LAST DAY:
% If it is necessary to start from a seperate section, the experimenter
% can include an argument for section:
% section = 1: before training
% section = 2: after devaluation (between training and extinction)
% section = 3: post experimental ratings and tasks

try
    %**************************************************************************
    %%       PTB INITIALIZATION/PARAMETER SETUP
    %**************************************************************************
    
    %clear all
    commandwindow
    % add the function folder to the path just for this session
    path(path, 'functions');
    
    % prompt the experimenter if to run the complete task or choosing a sequence:
    UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
    set(0, 'DefaultUIControlFontSize', 14);
    list = {'COMPLETE [DEFAULT]', 'section 1 (before MRI)', 'section 2 (after 1st MRI)', 'section 3 (after 2nd MRI)'};
    [indx,tf] = listdlg('ListSize',[250,100],'Name','Choose stage', 'PromptString', 'Select an option', 'CancelString', 'Cancel & EXIT', 'SelectionMode','single', 'ListString',list, 'InitialValue', 1);
    set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);
    if tf == 0
        error('*** Running ABORTED by the experimenter ***')
    end
    if indx-1 > 0 
        section = indx-1;
    end
    
    % relies any disables/restrictions of keys.
    DisableKeysForKbCheck([]);
    RestrictKeysForKbCheck([]);
    
    % get the response device index
    id = GetKeyboardIndices();
    var.deviceIndex = min(id);
    
    % enter the task variables
    var.sub_ID = input('***input*** SUBJECT NUMBER: ');
    % check validity of SUBJECT number:
    while isempty(var.sub_ID) || ~isa(var.sub_ID,'double') || var.sub_ID <= 100 || var.sub_ID >= 300 || var.sub_ID == 200
        var.sub_ID = input('SUBJECT NUMBER must be 101-199 or 201-299. SUBJECT NUMBER: ');
    end
    if var.sub_ID > 100 && var.sub_ID < 200
        var.session = 1;
        var.training = 1;
    elseif var.sub_ID > 200 && var.sub_ID < 300
        var.session = input('***input*** SESSION NUMBER (1,2 or 3 session day): '); % 1,2,or 3 session
        var.training = 3;
    end
    
    % check that task variable make sense
    var = inputCheck (var,1); % check that the file does not exist and that the last session file does exist
        
    % initialize task parameters
    [var, data] = initTask(var);
    
    if exist(var.resultFile, 'file')
        save (var.resultFile, 'data', '-append');
    else
        save(var.resultFile,'data');
    end
    
    %% SECTION #1 (before training)
    if ~exist('section', 'var') || (exist('section', 'var') && section == 1)
        %**************************************************************************
        %        INITIAL HUNGER AND PLEASANTNESS RATINGS
        %**************************************************************************
        showInstruction(var,'instructions/ratings.txt')
        WaitSecs(0.4);
        while 1
            [~, ~, keycode] = KbCheck(-3,2);
            keyresp = find(keycode);
            if ismember (keyresp, [var.centerLeftKey, var.centerRightKey])
                break
            end
        end
        
        images           = {var.sweetImage, var.saltyImage};
        names            = {'sweet', 'savory'};
        questionX        = {var.sweetLabelHebrew; var.saltyLabelHebrew};
        
        % Randomize the image list
        randomIndex     = randperm(length(images));
        images          = images(randomIndex);
        names           = names (randomIndex);
        questionX       = questionX(randomIndex);
        
        for i = 1:length(images)
            
            if var.session == 1     %pleasantness ratings for snacks after tasting each snack (only in session 1)
                %question = ['Please rate how pleasant the piece of ' char(questionX(i)) ' you just ate was'];
                question = [1491 1512 1490 47 1497 32 1489 1489 1511 1513 1492 32 1506 1491 32 1499 1502 1492 32 1492 1497 1514 1492 32 1502 1492 1504 1492 32 1506 1489 1493 1512 1498 32 1495 1514 1497 1499 1514 32 1492 questionX{i} 32 1513 1488 1499 1500 1514 32 1499 1512 1490 1506];
            else                    %pleasantness ratings for snacks they haven't tasted before (session 2&3)
                %question = ['Please rate how pleasant you would find a piece of ' char(questionX(i)) ' right now'];
                question = [1491 1512 1490 47 1497 32 1489 1489 1511 1513 1492 32 1506 1491 32 1499 1502 1492 32 1492 1497 1514 1492 32 1502 1492 1504 1492 32 1506 1489 1493 1512 1498 32 1495 1514 1497 1499 1514 32 questionX{i} 32 1506 1499 1513 1497 1493];
            end
            
            %data.initialRatings.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, 'very unpleasant', 'very pleasant');
            data.initialRatings.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, [1502 1488 1491 32 1500 1488 32 1502 1492 1504 1492], [1502 1488 1491 32 1502 1492 1504 1492]);
            
            Screen('TextStyle', var.w, 1);
            Screen('TextSize', var.w, 36);
            DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
            Screen('Flip', var.w);
            WaitSecs(1+rand(1,1));
            
        end
        saveByStage(var, data, 'pr1'); % backup - saving a separate file for each step
        
        % Rate Hunger level
        % -----------------
        %question = 'Please rate your current hunger level';
        question = [1491 1512 1490 47 1497 32 1489 1489 1511 1513 1492 32 1488 1514 32 1512 1502 1514 32 1492 1512 1506 1489 32 1492 1504 1493 1499 1495 1497 1514 32 1513 1500 1498];
        %data.initialRatings.hunger = likertScale(0, question, [1 2 3 4 5 6 7 8 9 10], var, 'very full', 'very hungry');
        data.initialRatings.hunger = likertScale(0, question, [1 2 3 4 5 6 7 8 9 10], var, [1513 1489 1506 47 1492 32 1502 1488 1491], [1512 1506 1489 47 1492 32 1502 1488 1491]);
        
        Screen('TextStyle', var.w, 1);
        Screen('TextSize', var.w, 36);
        DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
        Screen('Flip', var.w);
        WaitSecs(1+rand(1,1));
        
        saveByStage(var, data, 'hr1'); % backup - saving a separate file for each step
        save (var.resultFile, 'data', '-append');
        
        %**************************************************************************
        %                ACTIVE TASK INSTRUCTIONS AND PRACTICE                    %
        %**************************************************************************
        if var.session == 1 % we want this only for the first session
            
            var.instructionSpeed = 2; % time in s for the slides that do not wait for a participant response
            activeInstruction(var);
            
            %**********************************************************************
            % practice blocK
            
            showInstruction(var, 'instructions/practice1.txt')
            WaitSecs(0.4);
            while 1
                [~, ~, keycode] = KbCheck(-3,2);
                keyresp = find(keycode);
                if ismember (keyresp, var.mySafetyControl)
                    break
                end
            end

            showInstruction(var, 'instructions/practice2.txt')
            WaitSecs(0.4);
            KbWait(-3,2);
            
            % initialize just as time references for practice
            var.time_MRI = GetSecs();
            var.ref_end = 0;
            
            condition = [  1  2  0];% 1 = sweet 2 = salty; 0 = rest
            duration  = [ 20 20 20];
            [var.condition, var.duration] = loadRandList(condition, duration);
            
            for ii = 1:3 % 3 blocks for practice
                
                % show block
                var.ref_end = var.ref_end + var.duration(ii); % 20 or 40 s
                drawnActiveScreen (var,ii);
                % we do not save data of the practice blocks
                
            end
            
            showInstruction(var, 'instructions/question.txt')
            
            WaitSecs(0.4);
            while 1
                [~, ~, keycode] = KbCheck(-3,2);
                keyresp = find(keycode);
                if ismember (keyresp, var.mySafetyControl)
                    break
                end
            end
            
        end
        
        %**************************************************************************
        %                   A MESSAGE TO GO TO THE SCANNER                        %
        %**************************************************************************
        % first copy outputfile to dropbox:
        CopyOutputToDropbox4(var.sub_ID);
        
        showInstruction(var, 'instructions/goToScanner.txt')
        
        WaitSecs(0.4);
        while 1
            [~, ~, keycode] = KbCheck(-3,2);
            keyresp = find(keycode);
            if ismember (keyresp, var.mySafetyControl)
                break
            end
        end
        
        if (exist('section', 'var') && section == 1)
            data = endRun(var,data);
        end
    end
    
    
    %% SECTION #2 (after training and devaluation/ befor extinction)
    if ~exist('section', 'var') || (exist('section', 'var') && section == 2)
        %**************************************************************************
        %                    STIM_OUTCOME CONTIGENCY TEST                         %
        %**************************************************************************
        if var.session == 1 % first day only
            
            showInstruction(var,'instructions/ratings.txt')
            WaitSecs(0.4);
            while 1
                [~, ~, keycode] = KbCheck(-3,2);
                keyresp = find(keycode);
                if ismember (keyresp, [var.centerLeftKey, var.centerRightKey])
                    break
                end
            end
            
            % prepare the images
            images           = {var.sweet_fractal, var.salty_fractal, var.rest_fractal};
            % define names by condition
            names            = {'sweet'; 'salty'; 'baseline'};
            condition        = [      1;       2;         0 ];
            % Randomize the image list
            randomIndex      = randperm(length(images));
            images           = images(randomIndex);
            names            = names (randomIndex);
            condition        = condition(randomIndex);
            
            for i = 1:length(images)

                %question = ['When the fractal below was shown, was it more likely that a button press would result in a ' var.sweetLabel ' or a ' var.saltyLabel ' reward?'];
                question = [1499 1488 1513 1512 32 1492 1514 1502 1493 1504 1492 32 1500 1502 1496 1492 32 1492 1493 1508 1497 1506 1492 44 32 1492 1488 1501 32 1492 1497 1492 32 1505 1489 1497 1512 32 1497 1493 1514 1512 32 1513 1500 1495 1497 1510 1514 32 1499 1508 1514 1493 1512 32 1514 1493 1489 1497 1500 10 1500 1512 1493 1493 1495 32 1513 1500 32 var.sweetLabelHebrew 32 1488 1493 32 1513 1500 32 var.saltyLabelHebrew 63];
                %data.contingencyTest.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, [var.sweetLabel ' more likely'], [var.saltyLabel  ' more likely']);
                data.contingencyTest.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, [var.sweetLabelHebrew 32 1505 1489 1497 1512 32 1497 1493 1514 1512], [var.saltyLabelHebrew 32 1505 1489 1497 1512 32 1497 1493 1514 1512]);
                
                % recode the rating so that the higher = the more accurate for both
                % food related-fractals
                if condition(i) == 1
                    data.contingencyTest.(names{i}) = data.contingencyTest.(names{i}) * -1;
                end
                
                Screen('TextStyle', var.w, 1);
                Screen('TextSize', var.w, 36);
                DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
                Screen('Flip', var.w);
                WaitSecs(1+rand(1,1));
            end
            
            saveByStage(var, data, 'tc'); % backup - saving a separate file for each step
            save(var.resultFile, 'data', '-append');
  
            showInstruction(var, 'instructions/eatNow.txt')
            
            WaitSecs(0.4);
            while 1
                [~, ~, keycode] = KbCheck(-3,2);
                keyresp = find(keycode);
                if ismember (keyresp, var.mySafetyControl)
                    break
                end
            end
            
        end
      
        %**************************************************************************
        %               RATINGS AFTER DEVALULATION PROCEDURE                      %
        %**************************************************************************
        if var.training == 1 || (var.training ==3 && var.session == 3)% only if it's the last training session for the experimental group
            
            % ratings after devaluation
            showInstruction(var,'instructions/ratings.txt')
            WaitSecs(0.4);
            while 1
                [~, ~, keycode] = KbCheck(-3,2);
                keyresp = find(keycode);
                if ismember (keyresp, [var.centerLeftKey, var.centerRightKey])
                    break
                end
            end
            
            images           = {var.sweetImage, var.saltyImage};
            names            = {'sweet', 'salty'};
            questionX        = {var.sweetLabelHebrew; var.saltyLabelHebrew};
            
            % Randomize the image list
            randomIndex      = randperm(length(images));
            images           = images(randomIndex);
            names            = names (randomIndex);
            questionX        = questionX(randomIndex);
            
            for i = 1:length(images)
                
                %question = ['Please rate how pleasant you would find a piece of ' char(questionX(i)) ' right now'];
                question = [1491 1512 1490 47 1497 32 1489 1489 1511 1513 1492 32 1506 1491 32 1499 1502 1492 32 1514 1492 1497 1492 32 1502 1492 1504 1492 32 1506 1489 1493 1512 1498 32 1495 1514 1497 1499 1514 32 questionX{i} 32 1506 1499 1513 1497 1493];
                %data.finalRatings.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, 'very unpleasant', 'very pleasant');
                data.finalRatings.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, [1502 1488 1491 32 1500 1488 32 1502 1492 1504 1492], [1502 1488 1491 32 1502 1492 1504 1492]);
                
                Screen('TextStyle', var.w, 1);
                Screen('TextSize', var.w, 36);
                DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
                Screen('Flip', var.w);
                WaitSecs(1+rand(1,1));
                
            end
            saveByStage(var, data, 'pr2'); % backup - saving a separate file for each step
            
            % Rate Hunger level
            % -----------------
            %question = 'Please rate your current hunger level';
            question = [1491 1512 1490 47 1497 32 1489 1489 1511 1513 1492 32 1488 1514 32 1512 1502 1514 32 1492 1512 1506 1489 32 1492 1504 1493 1499 1495 1497 1514 32 1513 1500 1498];
            %data.finalRatings.hunger = likertScale(0, question, [1 2 3 4 5 6 7 8 9 10], var, 'very full', 'very hungry');
            data.finalRatings.hunger = likertScale(0, question, [1 2 3 4 5 6 7 8 9 10], var, [1513 1489 1506 47 1492 32 1502 1488 1491], [1512 1506 1489 47 1492 32 1502 1488 1491]);
            
            Screen('TextStyle', var.w, 1);
            Screen('TextSize', var.w, 36);
            DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
            Screen('Flip', var.w);
            WaitSecs(1+rand(1,1));
            
            saveByStage(var, data, 'hr2'); % backup - saving a separate file for each step
            save(var.resultFile, 'data', '-append');
            
            %**************************************************************************
            %               RATING OF FRACTAL IMAGES (pleasantness)                   %
            %**************************************************************************
            
            showInstruction(var,'instructions/ratings.txt')
            WaitSecs(0.4);
            while 1
                [~, ~, keycode] = KbCheck(-3,2);
                keyresp = find(keycode);
                if ismember (keyresp, [var.centerLeftKey, var.centerRightKey])
                    break
                end
            end
            
            % prepare the images
            images           = {var.sweet_fractal, var.salty_fractal, var.rest_fractal};
            % define names by condition
            names            = {'sweet'; 'salty'; 'baseline'};
            %condition        = [    1;         2;         0 ];
            % Randomize the image list
            randomIndex     = randperm(length(images));
            images          = images(randomIndex);
            names           = names (randomIndex);
            
            for i = 1:length(images)
                
                %question = 'Please rate the pleasantness of the fractal below';
                question = [1491 1512 1490 47 1497 32 1489 1489 1511 1513 1492 32 1499 1502 1492 32 1504 1506 1497 1502 1492 32 1506 1489 1493 1512 1498 32 1492 1514 1502 1493 1504 1492 32 1500 1502 1496 1492];
                %data.fractalLiking.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, 'very unpleasant', 'very pleasant');
                data.fractalLiking.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, [1502 1488 1491 32 1500 1488 32 1504 1506 1497 1502 1492], [1502 1488 1491 32 1504 1506 1497 1502 1492]);
                
                Screen('TextStyle', var.w, 1);
                Screen('TextSize', var.w, 36);
                DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
                Screen('Flip', var.w);
                WaitSecs(1+rand(1,1));
                
            end
            
            saveByStage(var, data, 'fr'); % backup - saving a separate file for each step
            save(var.resultFile, 'data', '-append');
        end
            %**************************************************************************
            %                   A MESSAGE TO GO TO THE SCANNER                        %
            %**************************************************************************
            % first copy outputfile to dropbox:
            CopyOutputToDropbox4(var.sub_ID);
            
            showInstruction(var, 'instructions/goToScanner.txt')
            
            WaitSecs(0.4);
            while 1
                [~, ~, keycode] = KbCheck(-3,2);
                keyresp = find(keycode);
                if ismember (keyresp, var.mySafetyControl)
                    break
                end
            end
            
            if (exist('section', 'var') && section == 2)
                data = endRun(var,data);
            end
    end
    
    
    %% SECTION #3 (post experiment tasks)
    if ~exist('section', 'var') || (exist('section', 'var') && section == 3)
        %**************************************************************************
        %                RATINGS AFTER COMPLETING PROCEDURE                       %
        %**************************************************************************
        if var.training == 1 || (var.training ==3 && var.session == 3) % only if it's the last training session for the experimental group
            
            % ratings after devaluation
            showInstruction(var,'instructions/ratings.txt')
            WaitSecs(0.4);
            while 1
                [~, ~, keycode] = KbCheck(-3,2);
                keyresp = find(keycode);
                if ismember (keyresp, [var.centerLeftKey, var.centerRightKey])
                    break
                end
            end
            
            images           = {var.sweetImage, var.saltyImage};
            names            = {'sweet', 'salty'};
            questionX        = {var.sweetLabelHebrew; var.saltyLabelHebrew};
            
            % Randomize the image list
            randomIndex      = randperm(length(images));
            images           = images(randomIndex);
            names            = names (randomIndex);
            questionX        = questionX(randomIndex);
            
            for i = 1:length(images)
                
                %question = ['Please rate how pleasant you would find a piece of ' char(questionX(i)) ' right now'];
                question = [1491 1512 1490 47 1497 32 1489 1489 1511 1513 1492 32 1506 1491 32 1499 1502 1492 32 1514 1492 1497 1492 32 1502 1492 1504 1492 32 1506 1489 1493 1512 1498 32 1495 1514 1497 1499 1514 32 questionX{i} 32 1506 1499 1513 1497 1493];
                %data.finalRatings.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, 'very unpleasant', 'very pleasant');
                data.postExperimentalRatings.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, [1502 1488 1491 32 1500 1488 32 1502 1492 1504 1492], [1502 1488 1491 32 1502 1492 1504 1492]);
                
                Screen('TextStyle', var.w, 1);
                Screen('TextSize', var.w, 36);
                DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
                Screen('Flip', var.w);
                WaitSecs(1+rand(1,1));
                
            end
            saveByStage(var, data, 'pr3'); % backup - saving a separate file for each step
            
            % Rate Hunger level
            % -----------------
            %question = 'Please rate your current hunger level';
            question = [1491 1512 1490 47 1497 32 1489 1489 1511 1513 1492 32 1488 1514 32 1512 1502 1514 32 1492 1512 1506 1489 32 1492 1504 1493 1499 1495 1497 1514 32 1513 1500 1498];
            %data.finalRatings.hunger = likertScale(0, question, [1 2 3 4 5 6 7 8 9 10], var, 'very full', 'very hungry');
            data.postExperimentalRatings.hunger = likertScale(0, question, [1 2 3 4 5 6 7 8 9 10], var, [1513 1489 1506 47 1492 32 1502 1488 1491], [1512 1506 1489 47 1492 32 1502 1488 1491]);
            
            Screen('TextStyle', var.w, 1);
            Screen('TextSize', var.w, 36);
            DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
            Screen('Flip', var.w);
            WaitSecs(1+rand(1,1));
            
            saveByStage(var, data, 'hr3'); % backup - saving a separate file for each step
            save(var.resultFile, 'data', '-append');
            
            data = endTask(var,data);
            % copy outputfile to dropbox:
            CopyOutputToDropbox4(var.sub_ID);
            
            %**************************************************************************
            %                       POST EXPERIMENTAL TASKS                           %
            %**************************************************************************
            
            %------------------ WORKING MEMORY (OSPAN TASK) ------------------%
            !open OSPAN/ospanTask/automatedospan_HIS.iqx
            fprintf('\n\nExperimenter: An external window of Inquisit lab now opened. Run the task there.\n\n')
            while 1
                toContinue = input('Experimenter: please enter continue after performing the task on Inquisit 5: \n', 's');
                if strcmp(toContinue, 'continue')
                    break
                end
            end
            
            %------------- 2-STEP TASK (BY COCKBURN and O'DOHERTY ------------%
            rmpath('functions')
            oldFolder = cd(fullfile('SpaceMiner', 'taskCode'));
            try
                run_Participant_BehaviorVersion(var.sub_ID);
            catch
                input('\n** The space miner task was not completed! **\n(either failed or terminated by the experimenter)\npress enter to continue\n')
            end
            cd(oldFolder);
            path(path, 'functions');
            
            %------------------------ QUESTIONNAIRES -------------------------%
            % a message for the experimenter to press ENTER to move to open
            % the questionnaires.
            system('osascript -e ''quit app "Terminal"''');
            system('osascript -e ''quit app "Safari"''');
            WaitSecs(2);
            fprintf('\n\nPress ENTER to open the questionnaires.\n');
            input('','s');
            system('open -a Safari https://forms.gle/EQGTwfkWPfq8M4Fc7');
            
            % copy outputfile to dropbox:
            CopyOutputToDropbox4(var.sub_ID);
        else
            data = endRun(var,data);
        end
    end
    %**************************************************************************
    %%                           END EXPERIMENT                               %
    %**************************************************************************
    
catch %#ok<*CTCH>
    % This "catch" section executes in case of an error in the "try"
    % section []
    % above.  Importantly, it closes the onscreen window if it's open.
    Screen('CloseAll');
    fclose('all');
    psychrethrow(psychlasterror);
end

end