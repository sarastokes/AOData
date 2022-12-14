classdef PulseBar < sara.protocols.spatial.Pulse
% PULSEBAR
%
% Description:
%   Individual bar presented as a decrement followed by an increment
%
% Constructor:
%   obj = PulseBar(stimTime, varargin)
%
% Parent class:
%   sara.protocols.spatial.Pulse
%
% Properties (set as optional key/value inputs):
%   numBars
%   barID
%   orientation
%
% Notes:
%   - If numBars is not divisible by canvasSize, the barWidth will be
%       rounded down with floor()
% -------------------------------------------------------------------------
    properties
        barID               % which bar to present (of numBars)
        numBars             % integer, ideally divisible by canvasSize
        orientation         % 'horizontal' or 'vertical'
    end

    properties (SetAccess = private)
        barWidth             % pixels
    end

    methods
        function obj = PulseBar(calibration, varargin)
            obj = obj@sara.protocols.spatial.Pulse(calibration, varargin{:});
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'NumBars', 8, @isnumeric);
            addParameter(ip, 'BarID', 1, @isnumeric);
            addParameter(ip, 'Orientation', 'vertical',... 
                @(x) ismember(x, {'vertical', 'horizontal'}));
            parse(ip, varargin{:});

            obj.numBars = ip.Results.NumBars;
            obj.orientation = ip.Results.Orientation;
            obj.barID = ip.Results.BarID;

            % Input checking
            assert(obj.barID > 0 & obj.barID <= obj.numBars,...
                'BarID must be between 1 and NumBars!');

            % Derived parameters
            switch obj.orientation
                case 'vertical'
                    obj.barWidth = floor(obj.canvasSize(1)/obj.numBars);
                case 'horizontal'
                    obj.barWidth = floor(obj.canvasSize(2)/obj.numBars);
            end
        end

        function stim = generate(obj)
            stim = obj.initStimulus();
            for i = 1:obj.totalPoints
                stim(:, (obj.barID-1) * obj.barWidth+1 : obj.barID*obj.barWidth, i) = trace(i);
            end
            
            if strcmp(obj.orientation, 'horizontal')
                stim = stim';
            end
        end

        function fName = getFileName(obj)
            fName = getFileName@sara.protocols.spatial.Pulse(obj);
            fName = [fName,'_', obj.orientation, ...
                sprintf('_bar_%uof%u', obj.barID, obj.numBars)];
        end
    end
end