classdef Stimulus < ao.core.Entity

    methods
        function obj = Stimulus(parent)
            obj.allowableParentTypes = {'aod.core.Epoch'};
            if nargin == 1
                obj.setParent(parent);
            end
        end
    end
end
