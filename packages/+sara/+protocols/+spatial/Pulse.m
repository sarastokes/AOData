classdef Pulse < sara.protocols.SpatialProtocol
% PULSE
%
% Description:
%   A spatially-uniform change in intenstiy
%
% Constructor:
%   obj = sara.protocols.spatial.Pulse(varargin)
%
% Inherited properties:
%   preTime
%   stimTime
%   tailTime
%   baseIntensity
%   contrast
%
% Inherited methods:
%   trace = temporalTrace(obj)
% -------------------------------------------------------------------------

    methods
        function obj = Pulse(calibration, varargin)
            obj = obj@sara.protocols.SpatialProtocol(calibration, varargin{:});
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(obj.canvasSize(1), obj.canvasSize(2), obj.totalSamples);
            
            preFrames = obj.sec2samples(obj.preTime);
            stimFrames = obj.sec2samples(obj.stimTime);
            stim(:, :, preFrames+1:preFrames+stimFrames) = obj.amplitude;
        end

        function fName = getFileName(obj)           
            if obj.tailTime == 0 && obj.baseIntensity == 0
                fName = sprintf('lights_on_%u_%u',...
                    abs(100*obj.contrast), obj.totalTime);
            elseif obj.tailTime == 0 && obj.contrast == -1
                fName = sprintf('lights_off_%u_%u',...
                    abs(100*obj.contrast), obj.totalTime);
            else
                [a, b] = sara.util.parseModulation(obj.baseIntensity, obj.contrast);
                fName = [sprintf('%s_%s_%up_%us_%ut', a, b,... 
                    abs(100*obj.contrast), obj.stimTime, obj.totalTime)];
            end
        end
    end
end