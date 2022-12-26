classdef TemporalModulation < sara.protocols.SpectralProtocol
% TEMPORALMODULATION
%
% Description:
%   A periodic temporal modulation
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Constructor:
%   obj = TemporalModulation(calibration, varargin)
%
% Properties:
%   preTime
%   stimTime
%   tailTime
%   baseIntensity
%   contrast
%   temporalFrequency               Hz
%   modulationClass                 'sinewave' or 'squarewave'           
% -------------------------------------------------------------------------
    properties
        temporalFrequency       % temporal frequency of modulation in Hz
        modulationClass         % 'sinewave' or 'squarewave'
    end
    
    methods
        function obj = TemporalModulation(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'TemporalFrequency', 5, @isnumeric);
            addParameter(ip, 'ModulationClass', 'square', ...
                @(x) ismember(x, {'square', 'sine'}));
            parse(ip, varargin{:});

            obj.temporalFrequency = ip.Results.TemporalFrequency;
            obj.modulationClass = ip.Results.ModulationClass;
        end
    end

    methods
        function stim = generate(obj)
            dt = 1 / obj.stimRate;
            t = dt:dt:obj.stimTime;
            stim = sin(2*pi*obj.temporalFrequency*t);
            if strcmp(obj.modulationClass, 'square')
                stim = sign(stim);
            end
            stim = (obj.amplitude * stim) + obj.baseIntensity;

            stim = obj.appendPreTime(stim);
            stim = obj.appendTailTime(stim);
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end
        
        function fName = getFileName(obj)
            if obj.contrast < 1
                contrastTxt = sprintf('%uc_', 100*obj.contrast);
            else
                contrastTxt = '';
            end

            
            tempFreq = num2str(obj.temporalFrequency);
            tempFreq = strrep(tempFreq, '.', 'p');
            
            fName = sprintf('%s_%s_%shz_%s%up_%ut',...
                lower(char(obj.spectralClass)), obj.modulationClass,... 
                tempFreq, contrastTxt,... 
                100*obj.baseIntensity, obj.totalTime);
        end
        
        function ledPlot(obj)
            ledPlot@sara.protocols.SpectralProtocol(obj);
        end
    end
end
