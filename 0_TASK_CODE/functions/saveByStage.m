function saveByStage(var, data, task, run)
% This function saves every step/run data separately as a backup and a
% potential reference if problems occur.

time = [datestr(now,'dd-mmm-yy_') datestr(now,'HH') 'h' datestr(now,'MM') 'm' datestr(now,'SS') 's'];

if isfield(var, 'runs') % as an indicator of running in the MRI code
    switch(task)
        case 'fo'
            fileName = strcat('data/dataByStage/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', task, '_run-', num2str(run,'%02.0f'), '_', time, '.mat');
        otherwise
            fileName = strcat('data/dataByStage/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_MRI_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', task,'_', time, '.mat');
    end
else
    fileName = strcat('data/dataByStage/', 'sub-', num2str(var.sub_ID, '%02.0f'), '_HIS_', num2str(var.training), 'day_session-',num2str(var.session,'%02.0f'),'_stage-', task,'_', time, '.mat');
end

% % handle the case that the file was saved in the same minute and create a
% % new one (if we do not record the seconds):
% if exist(fileName,'file')
%     v = 2; %version
%     fileName = [fileName(1:end-4) '_VER' num2str(v) '.mat'];
%     while exist(fileName,'file')
%         v = v+1;
%         fileName(end-4) = num2str(v);
%     end
% end

save(fileName, 'data');

end