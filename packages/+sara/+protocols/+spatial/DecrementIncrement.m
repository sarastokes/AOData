classdef DecrementIncrement < sara.protocols.SpatialProtocol
% DECREMENTINCREMENT
%
% Description:
%   A decrement followed by an increment, each half of stimTime
%
% Parent:
%   sara.protocols.SpatialProtocol
%
% Constructor:
%   obj = DecrementIncrement(stimTime, varargin)
%
% Properties:
%   stepTime                    Individual timing for the two modulations
% -------------------------------------------------------------------------
    properties (SetAccess = protected)
        stepTime        % Individual timing for the decrement and increment
    end

    methods 
        function obj = DecrementIncrement(varargin)
            obj = obj@sara.protocols.SpatialProtocol(varargin{:});

            % Derived properties
            obj.stepTime = obj.stimTime/2;
       end

        function trace = temporalTrace(obj)
            prePts = obj.sec2pts(obj.preTime);
            stepPts = obj.sec2pts(obj.stepTime);

            trace = obj.baseIntensity + zeros(1, obj.totalSamples);
            trace(prePts+1:prePts+stepPts) = obj.baseIntensity - obj.amplitude;
            trace(prePts+stepPts+1:prePts+(2*stepPts)) = obj.baseIntensity + obj.amplitude;
        end

        function stim = generate(obj)
            trace = obj.temporalTrace();

            stim = zeros(obj.canvasSize(1), obj.canvasSize(2), numel(trace));
            stim = stim + reshape(trace, [1 1 numel(trace)]);
        end

        function fName = getFileName(obj)
            fName = sprintf('decrement_increment_%us%ut', round(obj.stepTime), round(obj.totalTime));
        end
    end
end