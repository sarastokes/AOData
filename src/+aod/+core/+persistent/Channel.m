classdef Channel < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        Devices
    end

    methods
        function obj = Channel(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);

            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
            obj.Devices = obj.loadContainer('Devices');
        end
    end
end 