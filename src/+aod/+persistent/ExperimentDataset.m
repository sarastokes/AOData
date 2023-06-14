classdef ExperimentDataset < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% An Experiment dataset in an HDF5 file
%
% Description:
%   Represents a persisted ExperimentDataset in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.ExperimentDataset(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.ExperimentDataset

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = ExperimentDataset(hdfName, hdfPath, factory)
            obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    % aod.persistent.Entity methods
    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            % Add user-defined datasets and links
            obj.populateDatasetsAsDynProps();
            obj.populateLinksAsDynProps();
        end
    end
end 