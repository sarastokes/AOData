classdef ExperimentPanelHandler < EventHandler
%
% Superclass:
%   EventHandler
%
% Constructor:
%   obj = aod.app.query.ExperimentPanelHandler(parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = ExperimentPanelHandler(parent)
            obj = obj@aod.app.EventHandler(parent);
        end

        function handleRequest(obj, ~, evt)
            assignin('base', 'evt_ExptHandler', evt);
            switch evt.EventType 
                case "AddExperiment"
                    expt = string(evt.Trigger.Items)';
                    expt = cat(1, expt, evt.Data.FileName);
                    evt.Trigger.Items = expt;
                    obj.Parent.removeButton.Enable = "on";
                case "RemoveExperiment"
                    expt = setdiff(evt.Trigger.Items, evt.Data.FileName);
                    evt.Trigger.Items = expt;
                    if isempty(expt)
                        obj.Parent.removeButton.Enable = "off";
                    end
            end 
            obj.passRequest(evt);
        end

    end
end 