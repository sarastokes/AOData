classdef Baseline < sara.protocols.SpatialProtocol 
% BASELINE
%
% Description:
%   A constant display at baseIntensity
%
% Parent:
%   sara.protocols.SpatialProtocol
%
% Constructor:
%   obj = Baseline(calibration, varargin)
%
% Notes:
%   Contrast is set to 0, baseIntensity determines value. 
%   TailTime and PreTime are set to 0, stimTime determines timing
% ------------------------------------------------------------------------- 

    methods
        function obj = Baseline(calibration, varargin)
            obj = obj@sara.protocols.SpatialProtocol(...
                calibration, varargin{:});

            % Input checking
            assert(obj.stimTime>0, 'StimTime must be greater than 0');

            % Overwrite built-in properties
            obj.contrast = 0;
            obj.preTime = 0;
            obj.tailTime = 0;
        end
    end

    methods
        function trace = temporalTrace(obj)
            trace = obj.baseIntensity + zeros(1, obj.totalSamples);
        end

        function stim = generate(obj)
            stim = obj.temporalTrace();
        end

        function fName = getFileName(obj)
            fName = sprintf('baseline_%up_%ut', obj.baseIntensity, obj.totalTime);
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.stimTime;
        end
    end
end 