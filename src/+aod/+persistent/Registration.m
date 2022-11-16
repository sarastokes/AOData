classdef Registration < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops 
% REGISTRATION
%
% Description:
%   Represents a persisted Registration in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = Registration(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Registration
% -------------------------------------------------------------------------


    properties (SetAccess = protected)
        registrationDate
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

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.persistent.Registration([], [], []);
        end
    end
end