classdef GenFlags
    enumeration
        % Tasks      
        fo % free operant (i.e., the training)
        %tc % test contingency (i.e., stimulus-outcome contingency test)
        %wp % winnings presentation
        %dv % devaluation
        ex % extinction test
        ra % reacquisition test
        
        % for all:
        FixationStart
        RunStart
        TrialStart
        TrialEnd
        RunEnd
        
    end
    
    methods
        function text = str(GenFlags)
            text = char(GenFlags);
        end
    end
end


%%
