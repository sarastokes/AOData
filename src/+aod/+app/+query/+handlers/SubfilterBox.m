classdef SubfilterBox < aod.app.EventHandler 
%
% Parent:
%   EventHandler
%
% Constructor:
%   obj = aod.app.query.handlers.SubfilterBox(parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = SubfilterBox(parent)
            obj = obj@aod.app.EventHandler(parent, []);
        end

        function handleRequest(obj, ~, evt)
            assignin('base', 'evt', evt);

            switch evt.EventType
                case "ChangeFilterType"
                    obj.Parent.update(evt);
            end
        end
    end
end 