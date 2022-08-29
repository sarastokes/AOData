classdef Device < aod.core.persistent.Entity & dynamicprops

    methods
        function obj = Device(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);

            if ~isempty(dsetNames)
                obj.setDatasetsToDynProps(dsetNames);
            end
        end
    end
end