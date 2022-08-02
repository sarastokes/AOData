classdef TemporalModulation < patterson.protocols.SpectralProtocol
% TEMPORALMODULATION
%
% Description:
%   A periodic temporal modulation
%
% Parent:
%   patterson.protocols.SpectralProtocol
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
            obj = obj@patterson.protocols.SpectralProtocol(...
                calibration, varargin{:});

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
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
            ledValues = mapToStimulator@patterson.protocols.SpectralProtocol(obj);
        end
        
        function fName = getFileName(obj)
            if obj.contrast < 1
                contrastTxt = sprintf('%sc_', 100*obj.contrast);
            else
                contrastTxt = '';
            end
            fName = sprintf('%s_%s_%uhz_%s%up_%ut',...
                lower(char(obj.spectralClass)), obj.modulationClass,... 
                obj.temporalFrequency, contrastTxt,... 
                100*obj.baseIntensity, obj.totalTime);
        end
        
        function ledPlot(obj)
            ledPlot@patterson.protocols.SpectralProtocol(obj);
        end
    end
end
