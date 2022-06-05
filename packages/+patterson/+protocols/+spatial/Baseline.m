classdef Baseline < aod.builtin.stimuli.SpatialProtocol 
% BASELINE
%
% Description:
%   A constant display at baseIntensity (contrast set to 0)
%
% ------------------------------------------------------------------------- 

    methods
        function obj = Baseline(calibration, varargin)
            obj = obj@aod.builtin.stimuli.SpatialProtocol(calibration, varargin{:});

            obj.contrast = 0;
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
            fName = sprintf('Baseline%up%ut', obj.baseIntensity, obj.totalTime);
        end
    end
end 