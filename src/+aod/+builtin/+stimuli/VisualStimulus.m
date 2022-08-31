classdef VisualStimulus < aod.core.Stimulus 
% VISUALSTIMULUS
%
% Parent:
%   aod.core.Stimulus
%
% Constructor:
%   obj = VisualStimulus(protocol)
%
% -------------------------------------------------------------------------

    methods
        function obj = VisualStimulus(protocol)
            obj = obj@aod.core.Stimulus([], protocol);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = [];
            txt = strsplit(obj.protocolName, '_');
            for i = 1:numel(txt)
                value = [value, capitalize(txt{i})]; %#ok<AGROW> 
            end
        end
    end
end