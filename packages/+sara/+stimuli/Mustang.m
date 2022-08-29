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
        function obj = Mustang(value)
            obj@aod.builtin.stimuli.ImagingLight([], value, '%')
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('Mustang%u', round(obj.value));
        end
    end
end