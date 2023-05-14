classdef MatchPanel < aod.app.EventHandler 
%
% Parent:
%   aod.app.EventHandler
%
% Constructor:
%   obj = aod.app.query.MatchPanel(parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = MatchPanel(parent)
            obj = obj@aod.app.EventHandler(parent);
        end
    end

    methods
        function handleRequest(obj, ~, evt)
            if ismember(evt.EventType, ["SelectedNode", "DeselectedNode"])
                % Don't pass local events
                obj.Parent.update(evt);
            else
                obj.passRequest(evt);
            end
        end
    end
end 