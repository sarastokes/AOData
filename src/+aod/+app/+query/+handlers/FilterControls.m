classdef FilterControls < aod.app.EventHandler 
%
% Parent:
%   aod.app.EventHandler
%
% Constructor:
%   obj = aod.app.query.FilterControls(parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = FilterControls(parent)
            obj = obj@aod.app.EventHandler(parent, []);
        end
    end
end 