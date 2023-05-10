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
            assignin('base', 'QueryViewRequest', evt);
            switch evt.EventType 
                case "AddExperiment"
                    newExperiments = [];
                    for i = 1:numel(evt.Data.FileName)
                        pEXPT = loadExperiment(evt.Data.FileName(i));
                        newExperiments = cat(1, newExperiments, pEXPT);
                    end 
                    obj.Parent.QueryManager.addExperiment(newExperiments);
                    obj.Parent.update(evt);
                case "RemoveExperiment"
                    obj.Parent.QueryManager.removeExperiment(evt.Data.FileName);
                    obj.Parent.update(evt);
                case "PushFilter"
                    obj.Parent.QueryManager.addFilter( ...
                        obj.Parent.Filters(evt.Data.ID).getFilter());
                    obj.Parent.update(evt);
                case "SearchRequest"
            end
        end
    end
end 