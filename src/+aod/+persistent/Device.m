classdef Device < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% DEVICE
%
% Description:
%   Represents a persisted Device in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = Device(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Device
% -------------------------------------------------------------------------

    methods
        function obj = Device(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
        end
    end
    
    % Heterogeneous methods
    methods (Static, Sealed)
        function obj = empty()
            obj = aod.persistent.Device([], [], []);
        end
    end
end