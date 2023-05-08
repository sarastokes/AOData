classdef (ConstructOnLoad) ExperimentEvent < event.EventData 

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        Action
        Experiments  
    end

    methods 
        function obj = ExperimentEvent(action, expts)
            arguments 
                action          string 
                expts           aod.persistent.Experiment 
            end

            obj.Action = action;
            obj.Experiments = expts;
        end
    end
end 