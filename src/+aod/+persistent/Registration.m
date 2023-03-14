classdef Registration < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops 
% A Registration in an HDF5 file
%
% Description:
%   Represents a persisted Registration in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Registration(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Registration

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        registrationDate (1,1)          datetime
    end

    methods
        function obj = Registration(hdfFile, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            obj.registrationDate = obj.loadDataset("registrationDate");

            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
        end
    end
end