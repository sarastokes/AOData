classdef Channel < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% A Channel in an HDF5 file
%
% Syntax:
%   obj = aod.persistent.Channel(hdfName, hdfPath, factory)
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Channel(hdfName, hdfPath, factory)
%
% See Also:
%   aod.core.Channel

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = {?aod.persistent.Entity})
        DevicesContainer
    end

    methods
        function obj = Channel(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed)
        function add(obj, device)
            % ADD
            %
            % Description:
            %   Add a Device to the Channel and the HDF5 file
            %
            % Syntax:
            %   add(obj, device)
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
        end

        function populateContainers(obj)
            obj.DevicesContainer = obj.loadContainer('Devices');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Devices(obj, idx)

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