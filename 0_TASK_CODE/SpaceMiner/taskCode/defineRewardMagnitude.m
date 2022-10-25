function rewMagnitude = defineRewardMagnitude(taskStruct, numTrials, condReward)
    % reward magnitude observed for each trial
    rewMagnitude = nan(numTrials, 1);
    
    % define high reward magnitude trials
    isCondTrial = condReward == taskStruct.REWARD_HIGH;
    rewMagnitude( isCondTrial ) = normrnd(0.75, 0.1, sum(isCondTrial), 1);
    
    % define high reward magnitude trials
    isCondTrial = condReward == taskStruct.REWARD_LOW;
    rewMagnitude( isCondTrial ) = normrnd(0.25, 0.05, sum(isCondTrial), 1);
    
    
    % limit range of values to avoid loss
    rewMagnitude( rewMagnitude(:,1) < 0 ) = 0;
    rewMagnitude( rewMagnitude(:,1) > 1 ) = 1;
end