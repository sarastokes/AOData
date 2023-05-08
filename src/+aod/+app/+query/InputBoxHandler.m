classdef InputBoxHandler < aod.app.EventHandler 
%
% Parent:
%   EventHandler
%
% Constructor:
%   obj = aod.app.query.InputBoxHandler(parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = InputBoxHandler(parent)
            obj = obj@aod.app.EventHandler(parent, []);
        end
    end
end 