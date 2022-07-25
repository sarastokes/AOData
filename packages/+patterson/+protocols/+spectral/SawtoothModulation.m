classdef SawtoothModulation < patterson.protocols.SpectralProtocol
% TEMPORALMODULATION
%
% Description:
%   Periodic sawtooth modulation
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
%   polarityClass                   'positive' or 'negative'           
% -------------------------------------------------------------------------

    properties 
        temporalFrequency
        polarityClass
    end

    methods 
        function obj = SawtoothModulation(calibration, varargin)
            obj = obj@patterson.protocols.SpectralProtocol(...
                calibration, varargin{:});
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'TemporalFrequency', 5, @isnumeric);
            addParameter(ip, 'PolarityClass', 'positive',...
                @(x) ismember(x, {'positive', 'negative'}));
            parse(ip, varargin{:});

            obj.temporalFrequency = ip.Results.TemporalFrequency;
            obj.polarityClass = ip.Results.PolarityClass;
        end
    end

    methods
        function stim = generate(obj)
            dt = 1/obj.stimRate;
            t = dt:dt:obj.stimTime;

            stim = sawtooth(2 * pi * obj.temporalFrequency * t);
            stim = obj.amplitude * stim + obj.baseIntensity;

            if strcmp(obj.polarityClass, 'positive')
                stim = fliplr(stim);
            end

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
            if strcmp(obj.polarityClass, 'positive')
                polarityTxt = 'On';
            else
                polarityTxt = 'Off';
            end
            fName = sprintf('%s_%s_sawtooth_%uhz_%s%up_%ut_%s',...
                lower(char(obj.spectralClass)), polarityTxt,... 
                obj.temporalFrequency, contrastTxt,... 
                100*obj.baseIntensity, obj.totalTime);
        end
    end
end 