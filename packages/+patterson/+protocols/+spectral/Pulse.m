classdef Pulse < patterson.protocols.SpectralProtocol
% PULSE
% 
% Description:
%   An change in intensity from a specified background level
%
% Parent:
%   patterson.protocols.SpectralProtocol
%
% Constructor:
%   obj = Pulse(calibration, varargin)
%
% Inherited properties:
%   spectralClass           patterson.SpectralTypes
%   preTime
%   stimTime                
%   tailTime
%   contrast                
%   baseIntensity           
% -------------------------------------------------------------------------

    methods
        function obj = Pulse(calibration, varargin)
            obj = obj@patterson.protocols.SpectralProtocol(...
                calibration, varargin{:});
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(1, obj.totalPoints);

            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            stim(prePts+1:stimPts) = obj.amplitude + obj.baseIntensity;
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@patterson.protocols.SpectralProtocol(obj);
        end
        
        function fName = getFileName(obj)
            [a, b] = parseModulation(obj.baseIntensity, obj.contrast);
            if obj.baseIntensity == 0
                magVal = obj.amplitude;
            else
                magVal = obj.contrast;
            end
            fName = [sprintf('%s_%s_%s_%up_%us_%ut',...
                lower(char(obj.spectralClass)), a, b,... 
                abs(100*magVal), obj.stimTime, obj.totalTime)];
        end
        
        function ledPlot(obj)
            ledPlot@patterson.protocols.SpectralProtocol(obj,...
                obj.mapToStimulator());
        end
    end
end