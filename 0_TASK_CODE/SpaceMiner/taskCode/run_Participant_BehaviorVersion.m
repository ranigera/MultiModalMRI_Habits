function run_Participant_BehaviorVersion(subID)
%RE-ADDED TO THIS VERSION BY RANI

% run a participant through instructions, practice and then the task itself

% first some instructions
run_SpaceMarket_Instructions();

% then some practice
run_SpaceMarket_Practice(subID);

% then the task itself
run_SpaceMarket_behavioral(subID);

end