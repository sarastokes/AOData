classdef SpatialStimulus < aod.builtin.stimuli.VisualStimulus
% SPATIALSTIMULUS`
%
% Constructor:
%   obj = SpatialStimulus(protocol, basePower)
%
% Properties:
%   basePower
%
% Methods:
%   setBasePower(obj, value)
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        basePower
    end

    methods
        function obj = SpatialStimulus(protocol, basePower)
            obj = obj@aod.builtin.stimuli.VisualStimulus(protocol);
            
            if nargin > 1
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