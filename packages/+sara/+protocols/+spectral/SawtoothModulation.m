classdef SawtoothModulation < sara.protocols.SpectralProtocol
% TEMPORALMODULATION
%
% Description:
%   Periodic sawtooth modulation
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
%   polarityClass                   'positive' or 'negative'           
% -------------------------------------------------------------------------

    properties 
        temporalFrequency
        polarityClass
    end

    methods 
        function obj = SawtoothModulation(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
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

            W = obj.stimRate/obj.temporalFrequency;

            syms x y;
            stim = 1/W * (x-fix(x/W));

            %stim = sawtooth(2 * pi * obj.temporalFrequency * t);
            %stim = obj.amplitude * stim + obj.baseIntensity;

            if strcmp(obj.polarityClass, 'positive')
                stim = fliplr(stim);
            end

            stim = obj.appendPreTime(stim);
            stim = obj.appendTailTime(stim);
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            if obj.contrast < 1
                contrastTxt = sprintf('%sc_', 100*obj.contrast);
            else
                contrastTxt = '';
            end
            if strcmp(obj.polarityClass, 'positive')
                polarityTxt = 'on';
            else
                polarityTxt = 'off';
            end
            fName = sprintf('%s_%s_sawtooth_%uhz_%s%up_%ut',...
                lower(char(obj.spectralClass)), polarityTxt,... 
                obj.temporalFrequency, contrastTxt,... 
                100*obj.baseIntensity, obj.totalTime);
        end
    end
end 