classdef Channel < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        DevicesContainer
    end

    methods
        function obj = Channel(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);

            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
            obj.DevicesContainer = obj.loadContainer('Devices');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function obj = Devices(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).DevicesContainer(idx));
            end
        end
    end
end 