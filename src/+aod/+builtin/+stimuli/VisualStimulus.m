classdef VisualStimulus < aod.core.Stimulus 
% VISUALSTIMULUS
%
% Parent:
%   aod.core.Stimulus
%
% Constructor:
%   obj = VisualStimulus(protocol)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = VisualStimulus(protocol, varargin)
            obj = obj@aod.core.Stimulus([], protocol, varargin{:});
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = [];
            txt = strsplit(obj.protocolName, '_');
            for i = 1:numel(txt)
                value = [value, appbox.capitalize(txt{i})]; %#ok<AGROW> 
            end
        end
    end
end