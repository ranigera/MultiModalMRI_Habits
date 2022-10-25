function finishEyeTracking(use_eyetracker, edfFile, var, task, run)
%   Finishing eye tracking  %

if use_eyetracker
    %% ---------------------------
    % finish up: stop recording eye-movements,
    % close graphics window, close data file and shut down tracker
    Eyelink('StopRecording');
    %   Eyelink MSG
    % ---------------------------
    Eyelink('Message',['Eyetracking_closeTime: ',num2str(GetSecs-var.time_MRI)]);
    WaitSecs(.1);
    Eyelink('CloseFile');
    
    %%  Handle files
    % ---------------------------
    % assemble file name
    time = [datestr(now,'dd-mmm-yy_') datestr(now,'HH') 'h' datestr(now,'MM') 'm'];
    
    if isfield(var, 'runs') % as an indicator of running in the MRI code
        switch(task)
            case 'fo'
                fileNameToSave = strcat('data/eyeTrackerData/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', task, '_run-', num2str(run,'%02.0f'), '_', time, '.edf');
            otherwise
                fileNameToSave = strcat('data/eyeTrackerData/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', task,'_', time, '.edf');
        end
    else
        fileNameToSave = strcat('data/eyeTrackerData/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', task,'_', time, '.edf');
    end
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