classdef SpatialStimulus < aod.builtin.stimuli.VisualStimulus
% SPATIALSTIMULUS`
%
% Constructor:
%   obj = SpatialStimulus(parent, protocol, varargin)
%
% Properties:
%   basePower
% Inherited properties:
%   stimParameters
%
% Methods:
%   setBasePower(obj, value)
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        basePower
    end

    methods
        function obj = SpatialStimulus(parent, protocol, varargin)
            if nargin < 1
                parent = [];
            end
            obj = obj@aod.builtin.stimuli.VisualStimulus(parent, protocol);
            
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'BasePower', [], @isnumeric);
            parse(ip, varargin{:});
            
            if ~isempty(ip.Results.BasePower)
                obj.setBasePower(ip.Results.BasePower);
            end
        end

        function setBasePower(obj, value)
            % SETBASEPOWER
            %
            % Syntax:
            %   obj.setBasePower(value)
            % -------------------------------------------------------------
            arguments
                obj
                value(1,1)       {mustBeInRange(value, 0, 100)}
            end
            obj.basePower = value;
        end
    end
end