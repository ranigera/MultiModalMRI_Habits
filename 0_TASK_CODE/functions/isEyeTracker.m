function eyeTracker = isEyeTracker()
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 14);
eyeTracker = strcmp(questdlg('Use eytracker?','Eye Tracker','Yes','No','Yes'), 'Yes');
set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);
end