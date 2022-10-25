function rewPWin = defineRewardProbability(numTrials, numOutcomeStates, doRareTrans)
    
    % anchored probability of win for each option
    anchorePWin = randsample([1, 0], 2);
    
    % probability of win for each outcome across trials
    rewPWin = nan(numTrials, numOutcomeStates);
    % the anchored value from which values will drift
    rewPWinAnchore = zeros(size(rewPWin));
    
    % minimum # of trials before value resampling
    rewResamplePeriod = 10;
    numTrialPostResample = 0;
    % number of blocks since a reversal
    blocksPostReverse = 0;
    
    % sigmoid function parameters
    rewDecay = 1e3;
    rewDecaySlope = 1.5;
    asymtVal = 0.5;
    
    % define outcome (win/loss) for each trial
    for tI = 1 : numTrials
        % should we resample the reward probability of each outcome state
        if numTrialPostResample > rewResamplePeriod && doRareTrans(tI) == 1
            % force reversal if same ordering twice in a row
            if blocksPostReverse >= 2
                %anchorePWin = circshift(anchorePWin, 1);
                anchorePWin = circshift(anchorePWin, 1, 2); % Changed by Rani to match Matlab 2014b, as the circshift function was changed.
                blocksPostReverse = 0;
            elseif randsample([0 1], 1, true, [0.25, 0.75])
                % weighted reversal
                %anchorePWin = circshift(anchorePWin, 1);
                anchorePWin = circshift(anchorePWin, 1, 2); % Changed by Rani to match Matlab 2014b, as the circshift function was changed.
                blocksPostReverse = 0;
            end
            
            % reset the re-sample trial count
            numTrialPostResample = 0;
            blocksPostReverse = blocksPostReverse + 1;
        end
        
        % track reward magnitude for this trial
        rewPWinAnchore(tI,[1 2]) = anchorePWin(1);
        rewPWinAnchore(tI,[3 4]) = anchorePWin(2);
        % move each win probability toward the asymptote
        for oI = 1 : size(rewPWin,2)
            % check to see if we should drift up or down toward theasymptote
            if rewPWinAnchore(tI,oI) > asymtVal
                % drift down toward asymptote
                rewPWin(tI,oI) = (rewPWinAnchore(tI,oI)-asymtVal)/(1+(1/rewDecay)*exp(rewDecaySlope*numTrialPostResample)) + asymtVal;
            else
                rewPWin(tI,oI) = (asymtVal - rewPWinAnchore(tI,oI))./(1 + rewDecay*exp(-rewDecaySlope*numTrialPostResample)) + rewPWinAnchore(tI,oI);
            end
        end
        
        % update count post reward-resample
        numTrialPostResample = numTrialPostResample + 1;
    end
end