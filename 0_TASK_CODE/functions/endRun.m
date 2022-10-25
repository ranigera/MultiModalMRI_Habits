function data = endRun(var,data)

save(var.resultFile, 'data', '-append');
Screen('CloseAll');
ShowCursor;
RestrictKeysForKbCheck([]); %re-allow all keys to be read

end