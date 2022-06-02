classdef System < aod.core.Entity 

    properties (SetAccess = protected)
        Channels  
    end

    methods
        function obj = System(parent)
            obj.getAllowableParentTypes = {'aod.core.Dataset', 'aod.core.Empty'};
            if nargin < 1
                obj.setParent(parent);
            end
        end
    end

    methods %(SetAccess = ?aod.core.Creator)
        function addChannel(obj, channel)
            assert(ismember('aod.core.Channel', superclasses(channel)));
            obj.Channels = cat(1, obj.Channels, channel);
        end
    end
end 