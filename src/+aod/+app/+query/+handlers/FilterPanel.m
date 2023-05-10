classdef FilterPanel < aod.app.EventHandler 
%
% Parent:
%   aod.app.EventHandler
%
% Constructor:
%   obj = aod.app.query.FilterPanel(parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = FilterPanel(parent)
            obj = obj@aod.app.EventHandler(parent, []);
        end
    end
end 