function taskStruct = initTaskStruct()
    % initialize the random number stream
    RandStream.setGlobalStream(RandStream('mt19937ar','Seed','shuffle'));

    % define the block struture
    taskStruct = struct();
    % define condition label constants
    taskStruct.STATE_HIGH = 1;
    taskStruct.STATE_LOW = 2;
    % define block structure (typed token reward, or flexible)
    taskStruct.REWARD_HIGH = 1;
    taskStruct.REWARD_LOW = 2;
    % some structure parametes
    taskStruct.numOptions_1 = 2;
    % 4 potential 2nd states that can be transitioned into
    taskStruct.numSecondStates = 4;
    % three possible outcome state (2 for rewarded outcomes, and the 3rd for incorrect responses)
    taskStruct.numOutcomeStates = 4;
    
    % probability of rare tansition associated with each 1st level option
    taskStruct.pTransRare = 0.3;
end
