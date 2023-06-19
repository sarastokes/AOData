classdef Calibration < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% CALIBRATION
%
% Description:
%   Represents a persisted Calibration in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = aod.persistent.Calibration(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Calibration

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = {?aod.persistent.Entity, ?aod.persistent.Epoch})
        calibrationDate (1,1)            datetime 
    end

    methods
        function obj = Calibration(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            obj.assignProp('calibrationDate');
            
            % Add additional user-defined datasets and links
            obj.populateDatasetsAsDynProps();
            obj.populateLinksAsDynProps();
        end
    end
end