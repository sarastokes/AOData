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

            if ismember("calibrationDate", dsetNames)
                obj.calibrationDate = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, 'calibrationDate');
            end

            obj.setDatasetsToDynProps(dsetNames);
            obj.setLinksToDynProps(linkNames);
        end
    end
end