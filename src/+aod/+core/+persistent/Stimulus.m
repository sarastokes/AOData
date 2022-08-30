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

            if ismember("Calibration", linkNames)
                obj.Calibration = obj.loadLink(linkNames, "Calibration");
            end

            obj.setDatasetsToDynProps(dsetNames);
            obj.setLinksToDynProps(linkNames);
        end
    end
end 