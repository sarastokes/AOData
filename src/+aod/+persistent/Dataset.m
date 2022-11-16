classdef Dataset < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% DATASET
%
% Description:
%   Represents a persisted Dataset in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = Dataset(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Dataset
% -------------------------------------------------------------------------

    methods
        function obj = Dataset(hdfName, hdfPath, factory)
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
            obj = aod.persistent.Dataset([], [], []);
        end
    end
end