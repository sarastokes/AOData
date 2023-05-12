classdef EntityTree < aod.app.EventHandler 
%
% Parent:
%   aod.app.EventHandler
%
% Constructor:
%   obj = aod.app.query.EntityTree(parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = EntityTree(parent)
            obj = obj@aod.app.EventHandler(parent);
        end
    end
end 