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
%   obj = sara.stimuli.Mustang(parent, value)
%
% -------------------------------------------------------------------------
 
    methods
        function obj = Mustang(parent, value, units)
            if nargin < 3
                units = '%';
            end
            obj@aod.builtin.stimuli.ImagingLight(parent, value, units)
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('Mustang%u', obj.value);
        end
    end
end