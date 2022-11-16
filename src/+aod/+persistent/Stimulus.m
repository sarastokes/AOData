classdef Stimulus < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% STIMULUS
%
% Description:
%   Represents a persisted Stimulus in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = Stimulus(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Stimulus
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Calibration
    end

    methods
        function obj = Stimulus(hdfFile, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end
    
    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            obj.setDatasetsToDynProps();

            obj.Calibration = obj.loadLink("Calibration");
            obj.setLinksToDynProps();
        end
    end

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.persistent.Stimulus([], [], []);
        end
    end
end 