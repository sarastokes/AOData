classdef Step < sara.protocols.spectral.Pulse
% STEP
%
% Description:
%   A step up or down in intensity
%
% Parent:
%   sara.protocols.spectral.Pulse
%
% Constructor:
%   obj = Step(calibration, varargin)
%
% Inherited properties:
%   spectralClass           sara.SpectralTypes
%   preTime
%   stimTime                
%   tailTime                fixed at 0
%   contrast                
%   baseIntensity           
%
% Notes:
%   Specialized version of Pulse, separated for clarity
% -------------------------------------------------------------------------

    methods
        function obj = Step(calibration, varargin)
            obj = obj@sara.protocols.spectral.Pulse(...
                calibration, varargin{:});

            % Input checking
            if obj.spectralClass.isConeIsolating()
                error('Not implemented for cone-isolating classes');
            end
            if obj.baseIntensity ~= 0 && obj.contrast ~= -1
                error('STEP: Not implemented for lights up/down');
            end
            
            % Overwrites
            obj.tailTime = 0;
        end
        
        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(1, obj.totalPoints);

            prePts = obj.sec2pts(obj.preTime);
            stim(prePts+1:end) = obj.amplitude + obj.baseIntensity;
        end
        
        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.spectral.Pulse(obj);
        end

        function fName = getFileName(obj)
            if obj.baseIntensity == 0
                fName = sprintf('%s_lights_on_%up_%ut',...
                    char(obj.spectralClass), round(100*obj.contrast), obj.totalTime);
            else
                fName = sprintf('%s_lights_off_%up_%ut',...
                    char(obj.spectralClass), round(100*obj.baseIntensity), obj.totalTime);
            end
            fName = lower(fName);
        end
        
        function ledPlot(obj)
            ledPlot@sara.protocols.spectral.Pulse(obj);
        end
    end
    
    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + obj.stimTime;
        end
    end
end