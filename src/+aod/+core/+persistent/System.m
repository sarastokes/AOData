classdef System < aod.core.persistent.Entity & dynamicprops

    properties
        Channels 
    end

    methods 
        function obj = System(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);

            if ~isempty(dsetNames)
                obj.setDatasetsToDynProps(dsetNames);
            end

            obj.Channels = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Channels'), obj.factory);
        end
    end
end