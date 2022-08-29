classdef Stimulus < aod.core.Entity & matlab.mixin.Heterogeneous
% STIMULUS
%
% Description:
%   A stimulus presented during an Epoch
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
% 
% Constructor:
%   obj = aod.core.Stimulus(parent)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Calibration
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Epoch'};
    end
    
    methods
        function obj = Stimulus(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
        end
    end

    methods (Sealed)
        function setCalibration(obj, calibration)
            assert(isSubclass(calibration, 'aod.core.Calibration'),...
                'calibration must be subclass of aod.core.Calibration');
            obj.Calibration = calibration;
        end
    end
end
