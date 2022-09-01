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

            obj.analysisDate = obj.loadDataset(dsetNames, "analysisDate");
            obj.setDatasetsToDynProps(dsetNames);
            
            obj.setLinksToDynProps(linkNames);
        end 
    end
end 