classdef Calibration < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = private)
        calibrationDate(1,1)                    datetime 
    end

    methods
        function obj = Calibration(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);

            obj.calibrationDate = obj.loadDataset(dsetNames, 'calibrationDate');
            obj.setDatasetsToDynProps(dsetNames);
            
            obj.setLinksToDynProps(linkNames);
        end
    end
end