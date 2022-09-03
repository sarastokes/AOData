classdef Source < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        Sources 
    end

    methods
        function obj = Source(hdfFile, hdfName, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfName, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);
            
            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();           
            obj.Sources = obj.loadContainer('Sources');
        end
    end
end 