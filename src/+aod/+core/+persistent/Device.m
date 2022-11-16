classdef Device < aod.core.persistent.Entity ...
        & matlab.mixin.Heterogeneous & dynamicprops

    methods
        function obj = Device(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);

            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
        end
    end
    
    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.core.persistent.Device([], [], []);
        end
    end
end