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
%   obj = Calibration(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Calibration
% -------------------------------------------------------------------------


    properties (SetAccess = private)
        calibrationDate(1,1)                    datetime 
    end

    methods
        function obj = Calibration(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            obj.calibrationDate = obj.loadDataset('calibrationDate');
            obj.setDatasetsToDynProps();
            
            obj.setLinksToDynProps();
        end
    end

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.persistent.Calibration([], [], []);
        end
    end
end