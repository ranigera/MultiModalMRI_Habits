function doRareTrans = defineActionTransition(numTrials, pTransRare)
    % flag noting if a rare transition should occur on each trial
    doRareTrans = zeros(numTrials, 1);
    % define min/max ranges for periods without a rare transition
    minSeqLength = 1; maxSeqLength = 5;
    
    % define rare/common transition of each trial using the rules:
    % no rare too-close or to far from previous rare
    for tI = 1 : numTrials
        % compute the probability of a rare transition
        if tI-find(doRareTrans, 1, 'last') <= minSeqLength
            % don't allow 'rare' transition right after a preeceedign rare
            doRareTrans(tI) = 0;
        elseif (tI-find(doRareTrans, 1, 'last') >= maxSeqLength) | (all(doRareTrans == 0) && tI >= maxSeqLength)
            % force a rare transition if we haven't had one in a while
            doRareTrans(tI) = 1;
        else
            % weighted random sample to determin transtion type
            doRareTrans(tI) = randsample([1 0], 1, true, [pTransRare, 1-pTransRare]);
        end
    end % for each trial
end