classdef InputBox < aod.app.EventHandler 
%
% Parent:
%   aod.app.EventHandler
%
% Constructor:
%   obj = aod.app.query.InputBox(parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = InputBox(parent)
            obj = obj@aod.app.EventHandler(parent, []);
        end
    end
end 