classdef Mustang < aod.core.stimuli.ImagingLight 
% MUSTANG
%
% Constructor:
%   obj = patterson.stimuli.Mustang(parent, value)
% -------------------------------------------------------------------------
 
    methods
        function obj = Mustang(parent, value)
            obj@aod.core.stimuli.ImagingLight(parent, value)
        end
    end

    methods (Access = protected)
        function value = getDisplayName(obj)
            value = sprintf('Mustang%u', obj.Value);
        end
    end
end