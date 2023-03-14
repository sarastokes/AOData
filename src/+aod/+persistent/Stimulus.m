classdef Stimulus < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% STIMULUS
%
% Description:
%   Represents a persisted Stimulus in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Stimulus(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Stimulus, aod.util.Protocol

% By Sara Patterson, 2022 (AOData)
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
end 