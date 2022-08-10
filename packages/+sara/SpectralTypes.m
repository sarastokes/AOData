classdef SpectralTypes
% SPECTRALTYPES
%
% Description:
%   Enumeration of spectral stimulus types
%
% Methods:
%   tf = obj.isSpectral()
%   tf = obj.isConeIsolating()
%   txt = obj.getAbbrev()
%   rgb = obj.whichLEDs()
%   ledValues = obj.getStimulus(calibration)
%
% Static methods:
%   obj = SpectralTypes.init(name)
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
        Cyan
        Magenta
        Generic
    end

    methods 
        function tf = isSpectral(obj)
            import sara.SpectralTypes;
            
            switch obj
                case {SpectralTypes.Red, SpectralTypes.Green,...
                        SpectralTypes.Blue, SpectralTypes.Yellow,...
                        SpectralTypes.Cyan, SpectralTypes.Magenta}
                    tf = true;
                otherwise
                    tf = false;
            end
        end
        
        function tf = isConeIsolating(obj)
            import sara.SpectralTypes;
            switch obj
                case {SpectralTypes.Liso, SpectralTypes.Miso,...
                        SpectralTypes.Siso, SpectralTypes.LMiso,...
                        SpectralTypes.Isoluminance}
                    tf = true;
                otherwise
                    tf = false;
            end
        end

        function value = getAbbrev(obj)
            import sara.SpectralTypes;
            switch obj
                case SpectralTypes.Red
                    value = 'R';
                case SpectralTypes.Green
                    value = 'G';
                case SpectralTypes.Blue
                    value = 'B';
                case SpectralTypes.Yellow
                    value = 'Y';
                case SpectralTypes.Cyan
                    value = 'C';
                case SpectralTypes.Magenta
                    value = 'M';
                case SpectralTypes.Isoluminance
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
            import sara.SpectralTypes;
            switch obj
                case SpectralTypes.Red
                    value = [1 0 0];
                case SpectralTypes.Green
                    value = [0 1 0];
                case SpectralTypes.Blue
                    value = [0 0 1];
                case SpectralTypes.Yellow
                    value = [1 1 0];
                case SpectralTypes.Cyan
                    value = [0 1 1];
                case SpectralTypes.Magenta
                    value = [1 0 1];
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
            import sara.SpectralTypes;
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
        function obj = match(str)
            % MATCH
            %
            % Description:
            %   Search input text for spectral type, then initialize
            %
            % Syntax:
            %   obj = sara.SpectralTypes.match(str)
            % -------------------------------------------------------------
            import sara.SpectralTypes;
            
            str = lower(str);

            if contains(str, {'isoluminance', 'isolum'})
                obj = SpectralTypes.Isoluminance;
            elseif contains(str, {'luminance', 'achromatic', 'lmsx'})
                obj = SpectralTypes.Luminance;
            elseif contains(str, {'red'})
                obj = SpectralTypes.Red;
            elseif contains(str, {'green'})
                obj = SpectralTypes.Green;
            elseif contains(str, {'blue'})
                obj = SpectralTypes.Blue;
            elseif contains(str, {'yellow'})
                obj = SpectralTypes.Yellow;
            elseif contains(str, {'magenta'})
                obj = SpectralTypes.Magenta;
            elseif contains(str, {'cyan'})
                obj = SpectralTypes.Cyan;
            elseif contains(str, {'lmcone', 'lmiso'})
                obj = SpectralTypes.LMiso;
            elseif contains(str, {'scone', 'siso'})
                obj = SpectralTypes.Siso;
            elseif contains(str, {'mcone', 'miso'})
                obj = SpectralTypes.Miso;
            elseif contains(str, {'lcone', 'liso'})
                obj = SpectralTypes.Liso;
            else
                obj = [];
            end
        end

        function obj = init(str)
            % INIT
            %
            % Description:
            %   Initialize object from spectral type name
            %
            % Syntax:
            %   obj = sara.SpectralTypes.init(str)
            % -------------------------------------------------------------
            import sara.SpectralTypes;

            if isa(str, 'sara.SpectralTypes')
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
                case {'c', 'cyan'}
                    obj = SpectralTypes.Cyan;
                case {'p', 'magenta'}
                    obj = SpectralTypes.Magenta;
                otherwise
                    error('Unrecognized SpectralTypes: %s', str);
                    
            end
        end
    end
end