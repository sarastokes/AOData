classdef (Abstract) Source < aod.core.Entity 

    properties
        sourceParameters            % aod.core.Parameters
    end

    methods
        function obj = Source(parent)
            obj.allowableParentTypes = {'aod.core.Dataset', 'aod.core.Source', 'aod.core.Subject', 'aod.core.Empty'};
            % Check if a parent input was supplied
            if nargin > 0 && ~isempty(parent)
                obj.setParent(parent);
            end
            obj.sourceParameters = aod.core.Parameters();
        end
    end
end