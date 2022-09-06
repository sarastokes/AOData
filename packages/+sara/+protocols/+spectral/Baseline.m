classdef Baseline < sara.protocols.SpectralProtocol
% BASELINE
%
% Description:
%   A constant display at baseIntensity
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Constructor:
%   obj = Baseline(calibration, varargin)
%
% Inherited properties:
%   spectralClass           sara.SpectralTypes
%   preTime                 Fixed to 0
%   stimTime                
%   tailTime                Fixed to 0
%   contrast                Fixed to 0
%   baseIntensity           
%
% Notes:
%   Contrast is set to 0, baseIntensity determines value. 
%   TailTime and PreTime are set to 0, stimTime determines timing
%   SpectralClass set to Luminance if cone-isolating, which is equivalent
% ------------------------------------------------------------------------- 

    methods
        function obj = Baseline(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});
            
            % Input checking
            assert(obj.stimTime>0, 'StimTime must be greater than 0');

            % Overwrite built-in properties
            obj.contrast = 0;
            obj.preTime = 0;
            obj.tailTime = 0;
            if obj.spectralClass.isConeIsolating()
                obj.spectralClass = sara.SpectralTypes.Luminance;
            end
        end
    end

    methods
        function trace = temporalTrace(obj)
            trace = obj.baseIntensity + zeros(1, obj.totalPoints);
        end
        
        function stim = generate(obj)
            stim = obj.temporalTrace();
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            fName = sprintf('baseline_%up_%ut', round(100*obj.baseIntensity), obj.totalTime);
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.stimTime;
        end
    end
end 