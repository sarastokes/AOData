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
%   aod.core.Stimulus, aod.common.Protocol

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

            obj.Calibration = obj.loadLink("Calibration");

            % Add user-defined datasets and links
            obj.populateDatasetsAsDynProps();
            obj.populateLinksAsDynProps();
        end
    end
end 