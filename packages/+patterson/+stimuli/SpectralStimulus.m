classdef SpectralStimulus < aod.core.Stimulus 
% SPECTRALSTIMULUS
%
% Description:
%   A spectral stimulus produced by 3 LEDs modulated in time
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        presentation        timetable
        ledVoltages         timetable
    end

    properties (SetAccess = ?aod.core.Creator)
        stimFileName
    end

    properties (Hidden, Constant)
        calibrationType = 'ConeIsolation';
    end

    methods 
        function obj = SpectralStimulus(parent)
            if nargin < 1
                parent = [];
            end
            obj = obj@aod.core.Stimulus(parent);
        end
    end

    methods (Access = protected)
        function value = getDisplayName(obj)
            if ~isempty(obj.stimFileName)
                txt = strsplit(obj.stimFileName, '_');
                value = [];
                for i = 1:numel(txt)
                    phrase = txt{i};
                    if isletter(phrase(1))
                        phrase(1) = upper(phrase(1));
                    end
                    value = [value, phrase]; %#ok<AGROW> 
                end
            else
                value = 'Unknown';
            end
        end
    end

    methods (Access = ?aod.core.Creator)
        function addLedVoltages(obj, data)
            % TODO: Different import strategy
            obj.ledVoltages = data;
        end

        function addPresentation(obj, data)
            % TODO: Different import strategy
            obj.ledVoltages = data;
        end
    end
end 