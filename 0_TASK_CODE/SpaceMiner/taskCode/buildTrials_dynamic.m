function trials = buildTrials_dynamic(taskStruct, numTrials)

    % list all trials
    trials.trialID = (1:numTrials)';
    
    
    % define dynamic condition 
    %
    % min/max number of trials for a condition value
    minDuration_state = 10;
    maxDuration_state = 20;
    minDuration_reward = 7;
    maxDuration_reward = 15;
    % block types, and count indices for state transition condition
    transOrder = randsample([taskStruct.STATE_HIGH, taskStruct.STATE_LOW], 2);
    transCount = 0;
    transFlipCount = 0;
    trials.condState = nan(numTrials, 1);
    % for reward magnitude condiiton
    rewardCount = 0;
    rewardOrder = randsample([taskStruct.REWARD_LOW, taskStruct.REWARD_HIGH], 2);
    rewardFlipCount = 0;
    trials.condReward = nan(numTrials, 1);
    
    % loop through each trial
    for tI = 1 : numTrials
        transCount = transCount + 1;
        rewardCount = rewardCount + 1;

        % check to see if we should flip the state transition
        if transCount > maxDuration_state || (transCount > minDuration_state && rand(1) > 0.7)
            transOrder = fliplr(transOrder);
            transFlipCount = transFlipCount + 1;
            transCount = 0;
        end

        % check to see if we should flip the reward magnitude
        if rewardCount > maxDuration_reward || (rewardCount > minDuration_reward && rand(1) > 0.7)
            % force a switch
            rewardOrder = fliplr(rewardOrder);
            rewardFlipCount = rewardFlipCount + 1;
            rewardCount = 0;
        end

        % store state transition
        trials.condState(tI) = transOrder(1);
        % store reward magnitude condition
        trials.condReward(tI) = rewardOrder(1);
    end % for each trial
    
    
    % define aciton transitions
    trials.doRareTrans = defineActionTransition(numTrials, taskStruct.pTransRare);
    
    % define win/loss outcomes for each trial
    trials.rewPWin = defineRewardProbability(numTrials, taskStruct.numOutcomeStates, trials.doRareTrans);
    % convert mean reward probability into observations
    trials.rewBinary = (trials.rewPWin > rand(size(trials.rewPWin))) + 0;
    
    % define terminal state for each action according to transition probability and condition
    trials.state2 = defineOutcomeState(taskStruct, numTrials, taskStruct.numOptions_1, trials.doRareTrans, trials.condState);
    
    % define reward magnitude for each trial according to condition
    trials.rewMagnitude = defineRewardMagnitude(taskStruct, numTrials, trials.condReward);
    
    % convert to table
    trials = struct2table(trials);
    % add in event tracking
    trials = [trials, defineEventTracking(numTrials)];
end