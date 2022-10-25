function [] = run_SpaceMarket_Instructions()
    % initialize the IO for the task
    ioStruct = initIOStruct();
    showInstructions(ioStruct, fullfile('.', 'images', 'instructions'));
    
    % clear everything
    RestrictKeysForKbCheck( [] );
    ListenChar(1); ShowCursor();
    sca; 
end