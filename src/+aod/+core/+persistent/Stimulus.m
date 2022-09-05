classdef Stimulus < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        Calibration
    end

    methods
        function obj = Stimulus(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end
    
    methods (Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);

            obj.setDatasetsToDynProps();

            obj.Calibration = obj.loadLink("Calibration");
            obj.setLinksToDynProps();
        end
    end
end 