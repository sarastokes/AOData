classdef Step < patterson.protocols.SpectralProtocol
% STEP
% 
% Description:
%   An change in intensity from a specified background level
%
% Parent:
%   patterson.protocols.SpectralProtocol
%
% Constructor:
%   obj = Step(calibration, varargin)
% -------------------------------------------------------------------------

    methods
        function obj = Step(calibration, varargin)
            obj = obj@patterson.protocols.SpectralProtocol(...
                calibration, varargin{:});
        end

        function stim = generate(obj)
            stim = generate@patterson.protocols.SpectralProtocol(obj);
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@patterson.protocols.SpectralProtocol(obj);
        end
        
        function fName = getFileName(obj)
            if obj.tailTime == 0 && obj.baseIntensity == 0
                fName = sprintf('lights_on_%u_%u',...
                    abs(100*obj.contrast), obj.totalTime);
            elseif obj.tailTime == 0 && obj.contrast == -1
                fName = sprintf('lights_off_%u_%u',...
                    abs(100*obj.contrast), obj.totalTime);
            else
                [a, b] = parseModulation(obj.baseIntensity, obj.contrast);
                fName = [sprintf('%s_%s_%up_%us_%ut', a, b,... 
                    abs(100*obj.contrast), obj.stimTime, obj.totalTime)];
            end
        end
    end
end