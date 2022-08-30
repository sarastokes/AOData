classdef Timing < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        Time
    end

    methods
        function obj = Timing(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);

            if ismember("Time", dsetNames)
                obj.Time = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, "Time");
            end

            obj.setDatasetsToDynProps(dsetNames);
            obj.setLinksToDynProps(linkNames);
        end
    end
end 