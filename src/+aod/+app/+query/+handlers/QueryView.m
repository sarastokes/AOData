classdef QueryView < aod.app.EventHandler
% Event handler for main AOQuery user interface
%
% Superclass:
%   aod.app.EventHandler
% 
% Constructor:
%   obj = aod.app.query.handlers.QueryView(parent)
%
% See also:
%   aod.app.query.QueryView


% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = QueryView(parent)
            obj = obj@aod.app.EventHandler(parent);
        end

        function handleRequest(obj, ~, evt)
            switch evt.EventType 
                case "AddExperiment"
                    newExperiments = [];
                    for i = 1:numel(evt.Data.FileName)
                        pEXPT = loadExperiment(evt.Data.FileName(i));
                        newExperiments = cat(1, newExperiments, pEXPT);
                    end 
                    obj.Parent.Experiments = cat(1, obj.Parent.Experiments, newExperiments);
                    expt = evt.Trigger.Items;
                    if isempty(obj.Parent.QueryManager)
                        obj.Parent.QueryManager = aod.api.QueryManager(expt);
                    else
                        obj.Parent.QueryManager.addExperiment(newExperiments);
                    end
                    evt = aod.app.query.ExperimentEvent("Added", newExperiments);
                    %! Not sure about this
                    obj.Parent.update(evt);
                case "RemoveExperiment"
                    if isempty(evt.Trigger.Items)
                        obj.Parent.QueryManager = [];
                        %! Clear filter results
                    else
                        %! Trigger refilter
                    end 
            end
        end
    end
end 