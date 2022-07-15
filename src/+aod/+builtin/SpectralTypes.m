classdef SpectralTypes
% SPECTRALTYPES
%
% Description:
%   Enumeration of potential spectral types
% -------------------------------------------------------------------------

    enumeration
        Luminance      
        Isoluminance   
        Liso           
        Miso        
        Siso         
        LMiso       
        Red          
        Green        
        Blue         
        Yellow       
    end

    methods 
        function tf = isSpectral(obj)
            import aod.builtin.SpectralTypes;
            if obj == patterson.SpectralTypes.Red ...
                    || obj == SpectralTypes.Green...
                    || obj == SpectralTypes.Blue ...
                    || obj == SpectralTypes.Yellow
                tf = true;
            else
                tf = false;
            end
        end
        
        function tf = isConeIsolating(obj)
            import aod.builtin.SpectralTypes;
            if obj == SpectralTypes.Liso || SpectralTypes.Miso || ...
                    SpectralTypes.Siso || SpectralTypes.LMiso || ...
                    SpectralTypes.Isoluminance
                tf = true;
            else
                tf = false;
            end
        end

        function value = getAbbrev(obj)
            import aod.builtin.SpectralTypes;
            switch obj
                case SpectralTypes.Red
                    value = 'R';
                case SpectralTypes.Green
                    value = 'G';
                case SpectralTypes.Blue
                    value = 'B';
                case SpectralTypes.Yellow
                    value = 'Y';
                case SpectralTypes.Isouminance
                    value = 'Isolum';
                case SpectralTypes.Luminance
                    value = 'Lum';
                case SpectralTypes.Siso
                    value = 'S';
                case SpectralTypes.Miso
                    value = 'M';
                case SpectralTypes.Liso
                    value = 'L';
                case SpectralTypes.LMiso
                    value = 'LM';
            end
        end

        function value = whichLEDs(obj)
            import aod.builtin.SpectralTypes;
            switch obj
                case SpectralTypes.Red
                    value = [1 0 0];
                case SpectralTypes.Green
                    value = [0 1 0];
                case SpectralTypes.Blue
                    value = [0 0 1];
                case SpectralTypes.Yellow
                    value = [1 1 0];
                otherwise
                    value = [1 1 1];
            end
        end

        function ledValues = getStimulus(obj, cal, stim)
            % GETSTIMULUS
            %
            % Description:
            %   Convert normalized stimulus to RGB powers 
            %
            % Syntax:
            %   ledValues = getStimulus(obj, cal, stim)
            % -------------------------------------------------------------
            import aod.builtin.SpectralTypes;
            if obj.isSpectral
                % Assumes 1st value is background for all LEDs
                ledValues = zeros(3, numel(stim));
                ledList = obj.whichLEDs();
                for i = 1:3
                    if ledList(i)
                        ledValues(i, :) = (2*cal.stimPowers.Background(i)) * stim;
                    else
                        ledValues(i, :) = (2*cal.stimPowers.Background(i)) * stim(1);
                    end
                end
            elseif obj == SpectralTypes.Luminance
                ledValues = stim .* (2*cal.stimPowers.Background');
            elseif obj.isConeIsolating
                ledValues = cal.calcStimulus(obj.getAbbrev(), stim);
            end
        end
    end

    methods (Static)
        function obj = init(str)
            % INIT
            %
            % Description:
            %   Initialize object from spectral type name
            %
            % Syntax:
            %   obj = aod.builtin.SpectralTypes.init(str)
            % -------------------------------------------------------------
            import aod.builtin.SpectralTypes;

            if isa(str, 'aod.builtin.SpectralTypes')
                obj = str;
                return
            end
            
            switch lower(str)
                case {'w', 'luminance', 'achromatic', 'lum'}
                    obj = SpectralTypes.Luminance; 
                case {'l', 'lcone', 'liso', 'lisolating'}
                    obj = SpectralTypes.Liso;
                case {'m', 'mcone', 'miso', 'misolating'}
                    obj = SpectralTypes.Miso;
                case {'s', 'scone', 'siso', 'sisolating'}
                    obj = SpectralTypes.Siso;
                case {'lm', 'lmcone', 'lmiso', 'lmisolating'}
                    obj = SpectralTypes.LMiso;
                case {'isolum', 'isoluminance'}
                    obj = SpectralTypes.Isoluminance;
                case {'r', 'red'}
                    obj = SpectralTypes.Red;
                case {'g', 'green'}
                    obj = SpectralTypes.Green;
                case {'b', 'blue'}
                    obj = SpectralTypes.Blue;
                case {'y', 'yellow'}
                    obj = SpectralTypes.Yellow;
                otherwise
                    error('Unrecognized SpectralTypes: %s', str);
                    
            end
        end
    end
end