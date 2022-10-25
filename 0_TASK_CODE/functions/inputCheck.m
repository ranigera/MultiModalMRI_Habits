function var = inputCheck (var, time, task, run)

% make sure the input variables make sense and correct for possible
% mistakes
disp ('********************************************************************')
disp (['***input*** CHECKING INPUT: Check number: ' num2str(time)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% If session is not equal to one then check that the previous file is in the data folder

%FlushEvents();
KbQueueCreate();
KbQueueStart();
reenter = 0;

if var.session == 2 || var.session == 3 % for multiple sessions
    
    % name of the results file of the previos session
    if isfield(var, 'runs') % as an indicator of running in the MRI code
        NamePrevious  = (strcat('data/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session-1,'%02.0f'),'.mat'));
    else
        NamePrevious  = (strcat('data/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_', num2str(var.training), 'day_session-',num2str(var.session-1,'%02.0f'),'.mat'));
    end
    
    if ~exist(NamePrevious, 'file')
        beep;
        disp ('***input*** the previous session of this participant is not in the data folder');
        disp ('***input*** press space to continue or enter to re-enter the experiment inputs');
        decide = 0;
        
        while decide == 0
            [down, keyCode]=KbQueueCheck();
            
            keyresp = find(keyCode);
            
            if (down == 1)
                if ismember (keyresp,KbName('space'))
                    
                    disp ('***input*** continuing even if previous session is not in the data folder');
                    decide = 1;
                    
                elseif ismember (keyresp, KbName('Return'))
                    
                    reenter = 1;
                    decide = 1;
                    
                end
                
            end
            
        end
        
        KbQueueRelease();
        
    end
    
end


if reenter
    var.sub_ID = input('***input*** SUBJECT NUMBER: ');
    % check validity of SUBJECT number:
    while isempty(var.sub_ID) || ~isa(var.sub_ID,'double') || var.sub_ID <= 100 || var.sub_ID >= 300 || var.sub_ID == 200
        var.sub_ID = input('SUBJECT NUMBER must be 101-199 or 201-299. SUBJECT NUMBER: ');
    end
    if var.sub_ID > 100 && var.sub_ID < 200
        var.session = 1;
        var.training = 1;
    elseif var.sub_ID > 200 && var.sub_ID < 300
        var.session = input('***input*** SESSION NUMBER (1, 2 or 3 session day): '); % 1,2,or 3 session
        % check validity of SESSION number:
        while isempty(var.session) || ~ismember(var.session,1:3)
            var.session = input('SESSION NUMBER must be 1, 2 or 3. SESSION NUMBER: '); % 1,2,or 3 session
        end
        var.training = 3;
    end
    time=time+1;
    inputCheck(var, time)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check that the file does not already exist to avoid overwriting

% name of the results file of the current session
if isfield(var, 'runs') % as an indicator of running in the MRI code
    NameCurrent = strcat('data/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'.mat');
else
    NameCurrent = strcat('data/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'.mat');
end

if exist(NameCurrent,'file')
    if isfield(var, 'runs') % as an indicator of running in the MRI code
        if ~(strcmp(task, 'fo') && run == 1) % i.e., if it is not the first run in the MRI of this day
            copyfile(NameCurrent, ['data/replacedFiles/' NameCurrent(6:end-4) '_ReplacedAt' datestr(now,'dd-mm-yy_HH-MM-SS') '.mat']);
            load(NameCurrent, 'data')
        end
    else
        opt.Default = 'Cancel';
        opt.Interpreter = 'tex';
        resp=questdlg({['\fontsize{16}\bfThe file ' NameCurrent ' already exists.']; '\rmDo you want to:' ; '\bf1) Cancel' ; '2) Overwrite it\rm (the data will be overwritten, yet a backup file will be saved)' ; '\bf3) Load the existing one and use it \rm(a backup file will be saved)'},...
            'File exists warning','Cancel', 'Overwrite', 'Load', opt);
        if strcmp(resp,'Cancel') % Abort experiment if overwriting was not confirmed
            error('USING THE FILE WAS NOT CONFIRMED: EXPERIMENT ABORTED!');
        elseif strcmp(resp,'Overwrite')
            movefile(NameCurrent, ['data/replacedFiles/' NameCurrent(6:end-4) '_ReplacedAt' datestr(now,'dd-mm-yy_HH-MM-SS') '.mat']);
        elseif strcmp(resp,'Load')
            copyfile(NameCurrent, ['data/replacedFiles/' NameCurrent(6:end-4) '_ReplacedAt' datestr(now,'dd-mm-yy_HH-MM-SS') '.mat']);
            load(NameCurrent, 'data')
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check that the stage and run were not already conducted (especially importnant if it is in the MRI):
% verify the order for the MRI task runs correctly:
% Not doing again the sam stage/run and not missing a stage.

if isfield(var, 'runs') % as an indicator of running in the MRI code
    taskOrderVerification(var, task, run)
end

end