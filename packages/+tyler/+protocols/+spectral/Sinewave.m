classdef Sinewave < sara.protocols.spectral.TemporalModulation
% Tyler's cone-isolating sinewave stimulus code, placed in AOData class 
% with minimal modifications (using calibration rather than typing in 
% numbers for max/min/avg power per LED).

    properties
        controlFlag         logical     = false
    end

    methods
        function obj = Sinewave(calibration, varargin)
            obj@sara.protocols.spectral.TemporalModulation(...
                calibration, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'Control', false, @islogical);
            parse(ip, varargin{:});

            obj.controlFlag = ip.Results.Control;
            
            % Overwrite default properties
            obj.preTime = 0; obj.tailTime = 0; obj.stimTime = 80;
            obj.baseIntensity = 0.5; obj.contrast = 1;
            obj.modulationClass = 'sine';
            obj.temporalFrequency = 0.15; 
        end

        function LED_sins = generate(obj)
            tstep = 1/obj.STIM_RATE;

            t = 0:tstep:obj.stimTime;
            
            LED_sins = zeros(length(t),3); %creates the full array with all the LED sinusoids

            avgpwr_660 = obj.calibraiton.stimPowers.Background(1);
            avgpwr_530 = obj.calibraiton.stimPowers.Background(2);
            avgpwr_420 = obj.calibraiton.stimPowers.Background(3);

            if obj.controlFlag
                LED_sins(:,1) = avgpwr_660;
                LED_sins(:,2) = avgpwr_530;
                LED_sins(:,3) = avgpwr_420;
                return 
            end
            
            abbrev = obj.spectralClass.getAbbrev();
            powers = obj.calibration.stimPowers{:, abbrev};
            maxpwr_660 = powers(1); maxpwr_530 = powers(2); maxpwr_420 = powers(1);

            phase_660 = 0; phase_530 = 0; phase_420 = 0;
            
            sin_660 = avgpwr_660 + (maxpwr_660-avgpwr_660)*sin(2*pi*freq.*t + phase_660); % creates the sinusoid for the first led

            sin_530 = avgpwr_530 + (maxpwr_530-avgpwr_530)*sin(2*pi*freq.*t + phase_530); % creates the sinusoid for the second led

            sin_420 = avgpwr_420 + (maxpwr_420-avgpwr_420)*sin(2*pi*freq.*t + phase_420); % creates the sinusoid for the third led

            LED_sins(:,1) = sin_660'; LED_sins(:,2) = sin_530'; LED_sins(:,3) = sin_420'; 
        end

        function ledValues = mapToStimulator(obj)
            ledValues = obj.generate();
        end 
        
        function ledPlot(obj)
            ledPlot@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
        
            if obj.controlFlag 
                fName = 'control_nd1.0';
                return
            end

            import sara.SpectralTypes
            
            switch obj.spectralClass 
                case SpectralTypes.Liso
                    fName = 'l_isolating_0.15hz_nd1.0';
                case SpectralTypes.Miso
                    fName = 'm_isolating_0.15hz_nd1.0';
                case SpectralTypes.Siso
                    fName = 's_isolating_0.15hz_nd1.0';
                case SpectralTypes.Luminance
                    fName = 'luminance_0.15hz_nd1.0';
            end
        end
    end
end