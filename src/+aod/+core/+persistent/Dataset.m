classdef Dataset < aod.core.persistent.Dataset & dynamicprops

    methods
        function obj = Device(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);

            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
        end
    end
end