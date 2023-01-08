classdef Mustang < aod.builtin.stimuli.ImagingLight 
% MUSTANG
%
% Description:
%   GCaMP6 imaging light at 488 nm
%
% Parent:
%   aod.builtin.stimuli.ImagingLight
%
% Constructor:
%   obj = sara.stimuli.Mustang(value)
%
% -------------------------------------------------------------------------
 
    methods
        function obj = Mustang(intensity)
            obj@aod.builtin.stimuli.ImagingLight([], intensity,...
                'IntensityUnits', "%")
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('Mustang%u', round(obj.intensity));
        end
    end
end