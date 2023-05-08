classdef SubfilterBoxHandler < aod.app.EventHandler 
%
% Parent:
%   EventHandler
%
% Constructor:
%   obj = aod.app.query.SubfilterBoxHandler(parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = SubfilterBoxHandler(parent)
            obj = obj@aod.app.EventHandler(parent, []);
        end
    end
end 