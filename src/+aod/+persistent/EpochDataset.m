classdef EpochDataset < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% An Epoch dataset in an HDF5 file
%
% Description:
%   Represents a persisted EpochDataset in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.EpochDataset(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.EpochDataset

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = EpochDataset(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            % Add user-defined datasets and link
            obj.populateDatasetsAsDynProps();
            obj.populateLinksAsDynProps();
        end
    end
end