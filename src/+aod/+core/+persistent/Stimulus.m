classdef Stimulus < aod.core.persistent.Entity & dynamicprops

    properties
        Calibration
    end

    methods
        function obj = Stimulus(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end
    
    methods (Access = protected)
        function populate(obj)
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);

            obj.setDatasetsToDynProps(dsetNames);

            obj.Calibration = obj.loadLink(linkNames, "Calibration");
            obj.setLinksToDynProps(linkNames);
        end
    end
end 