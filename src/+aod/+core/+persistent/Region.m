classdef Region < aod.core.persistent.Entity & dynamicprops 

    properties (SetAccess = protected)
        Data 
        Source 
    end

    methods 
        function obj = Region(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);

            % DATASETS
            obj.Data = obj.loadDataset("Data");

            % LINKS
            obj.Source = obj.loadLink("Source");
        end
    end
end