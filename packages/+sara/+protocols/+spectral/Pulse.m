classdef Pulse < sara.protocols.SpectralProtocol
% PULSE
% 
% Description:
%   An change in intensity from a specified background level
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Constructor:
%   obj = Pulse(calibration, varargin)
%
% Inherited properties:
%   spectralClass           sara.SpectralTypes
%   preTime
%   stimTime                
%   tailTime
%   contrast                
%   baseIntensity           
% -------------------------------------------------------------------------

    methods
        function obj = Pulse(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(1, obj.totalPoints);

            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            stim(prePts+1:prePts+stimPts) = obj.amplitude + obj.baseIntensity;
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end
        
        function fName = getFileName(obj)
            [a, b] = sara.util.parseModulation(obj.baseIntensity, obj.contrast);
            if obj.baseIntensity == 0
                magVal = sprintf('%ui', round(100*obj.amplitude));
            else
                magVal = sprintf('%uc', round(100*obj.contrast));
            end

            fName = [sprintf('%s_%s_%s_%s_%up_%us_%ut',...
                lower(char(obj.spectralClass)), a, b,... 
                magVal, round(100*obj.baseIntensity),... 
                obj.stimTime, obj.totalTime)];
        end
        
        function ledPlot(obj)
            ledPlot@sara.protocols.SpectralProtocol(obj,...
                obj.mapToStimulator());
        end
    end
end