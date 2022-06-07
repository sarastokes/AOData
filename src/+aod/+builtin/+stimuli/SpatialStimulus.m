classdef SpatialStimulus < aod.builtin.stimuli.VisualStimulus
% SPATIALSTIMULUS`
%
% Constructor:
%   obj = SpatialStimulus(parent, protocol, basePower)
%
% Properties:
%   basePower
% Inherited properties:
%   stimParameters
%
% Methods:
%   setBasePower(obj, value)
% Inherited methods:
%   addParameter(obj, paramName, paramValue)
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        basePower
    end

    methods
        function obj = SpatialStimulus(parent, protocol, basePower)
            if nargin < 1
                parent = [];
            end
            obj = obj@aod.builtin.stimuli.VisualStimulus(parent, protocol);
            if nargin > 2
                obj.setBasePower(basePower);
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