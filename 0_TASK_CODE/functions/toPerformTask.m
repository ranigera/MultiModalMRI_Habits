function performTask = toPerformTask(taskWithStatus)
% check the status of the relevant task
if strcmp(taskWithStatus(end), 'V')
    performTask = strcmp(questdlg('This phase marked as already being performed. Are you sure you want to continue?','Marked as completed.','Yes','No','No'), 'Yes');
elseif ~strcmp(taskWithStatus(end), '*')
    performTask = strcmp(questdlg('This phase is not the one expected to run next. Are you sure you want to continue?','Not the next one expected.','Yes','No','No'), 'Yes');
else
    performTask = true;
end

end