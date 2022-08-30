classdef Analysis < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        analysisDate
    end

    methods
        function obj = Analysis(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);

            if ismember("analysisDate", dsetNames)
                obj.analysisDate = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, "analysisDate");
            end

            obj.setDatasetsToDynProps(dsetNames);
            obj.setLinksToDynProps(linkNames);
        end 
    end
end 