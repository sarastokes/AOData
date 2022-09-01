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

            obj.setDatasetsToDynProps(dsetNames);
            obj.setLinksToDynProps(linkNames);
            obj.Channels = obj.loadContainer('Channels');
        end
    end
end