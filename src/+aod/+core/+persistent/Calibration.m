classdef Calibration < aod.core.persistent.Entity ...
        & matlab.mixin.Heterogeneous & dynamicprops

    properties (SetAccess = private)
        calibrationDate(1,1)                    datetime 
    end

    methods
        function obj = Calibration(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);

            obj.calibrationDate = obj.loadDataset('calibrationDate');
            obj.setDatasetsToDynProps();
            
            obj.setLinksToDynProps();
        end
    end

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.core.persistent.Calibration([], [], []);
        end
    end
end