classdef Channel < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops

    properties (SetAccess = protected)
        DevicesContainer
    end

    methods
        function obj = Channel(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed)
        function addDevice(obj, device)
            % ADDDEVICE
            %
            % Description:
            %   Add a Device to the Channel and the HDF5 file
            %
            % Syntax:
            %   addDevice(obj, device)
            % -------------------------------------------------------------
            arguments
                obj 
                device          {mustBeA(device, 'aod.core.Device')}
            end

            device.setParent(obj);
            obj.addEntity(device);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

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

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.persistent.Channel([], [], []);
        end
    end
end 