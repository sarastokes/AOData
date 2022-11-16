classdef Analysis < aod.persistent.Entity ...
    matlab.mixin.Heterogeneous & dynamicprops

    properties (SetAccess = protected)
        analysisDate                    
    end

    methods
        function obj = Analysis(hdfFile, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            obj.analysisDate = obj.loadDataset("analysisDate");
            obj.setDatasetsToDynProps();
            
            obj.setLinksToDynProps();
        end 
    end
    
    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.persistent.Analysis([], [], []);
        end
    end
end 