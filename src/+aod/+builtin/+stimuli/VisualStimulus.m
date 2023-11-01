classdef VisualStimulus < aod.core.Stimulus
% A visual stimulus built from a Protocol
%
% Parent:
%   aod.core.Stimulus
%
% Constructor:
%   obj = aod.builtin.stimuli.VisualStimulus(protocol)
%   obj = aod.builtin.stimuli.VisualStimulus
%
% See also:
%   aod.common.Protocol

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    % TODO: Put protocol information here, not in Stimulus

    methods
        function obj = VisualStimulus(protocol, varargin)
            obj = obj@aod.core.Stimulus([], protocol, varargin{:});
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = [];
            if contains(obj.protocolName, '_')
                txt = strsplit(obj.protocolName, '_');
            elseif contains(obj.protocolName, '.')
                txt = strsplit(obj.protocolName, '.');
            else
                value = obj.protocolName;
                return
            end
            for i = 1:numel(txt)
                value = [value, appbox.capitalize(txt{i})]; %#ok<AGROW>
            end
        end
    end
end