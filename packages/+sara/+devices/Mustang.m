classdef Mustang < aod.builtin.devices.LightSource

    properties (Dependent)
        Calibrations
    end

    methods
        function obj = Mustang(parent, varargin)
            obj = obj@aod.builtin.devices.LightSource(488, varargin{:});
        end

        function value = get.Calibrations(obj)
            parent = obj.ancestor('aod.core.Experiment');
            value = parent.getCalibration('sara.calibrations.MustangPower');
        end
    end
end