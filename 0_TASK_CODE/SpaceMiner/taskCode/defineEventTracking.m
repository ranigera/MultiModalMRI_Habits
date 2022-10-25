function tracking = defineEventTracking(numTrials)
    % to store task events as the unfold
    outcome1 = nan(numTrials, 1);
    outcome2 = nan(numTrials, 1);
    outcomeBin = nan(numTrials, 1);
    outcomeMag = nan(numTrials, 1);
    resp1 = nan(numTrials, 1);
    resp2 = nan(numTrials, 1);
    RT1 = nan(numTrials, 1);
    RT2 = nan(numTrials, 1);
    
    % to store event times
    tStart = nan(numTrials, 1);
    tFixOn = nan(numTrials, 1);
    tStim1On = nan(numTrials, 1);
    tResp1 = nan(numTrials, 1);
    tStim1Off = nan(numTrials, 1);
    tStim2On = nan(numTrials, 1);
    tResp2 = nan(numTrials, 1);
    tFBOn = nan(numTrials, 1);
    tFBOff = nan(numTrials, 1);
    
    % set up intertrial jitters
    %
    % time between 1st stage response and display of 2nd state
    jitterResp1 = unifrnd(0.75, 0.75, numTrials, 1);
    % time between 2nd stage response and outcome feedback
    jitterFB = unifrnd(0.0, 0.0, numTrials, 1);
    % time between trials
    jitterITI = unifrnd(0.5, 0.5, numTrials, 1);
%     jitterITI = linspace(0.5, 4, numTrials)';
    jitterITI = jitterITI(randperm(length(jitterITI)));
    
    tracking = table(outcome1, outcome2, outcomeBin, outcomeMag, resp1, resp2, RT1, RT2,...
        tStart, tFixOn, tStim1On, tResp1, tStim1Off, tStim2On, tResp2, tFBOn, tFBOff,...
        jitterResp1, jitterFB, jitterITI);
end