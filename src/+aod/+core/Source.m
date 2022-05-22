classdef (Abstract) Source < aod.core.Entity 

    methods
        function obj = Source(parent)
            obj.allowableParentTypes = {'aod.core.Dataset', 'aod.core.Source'};
            % Check if a parent input was supplied
            if nargin > 0 && ~isempty(parent)
                obj.addParent(parent);
            end
        end
    end
end