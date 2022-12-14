classdef PulseSpacedBars < sara.protocols.spatial.Pulse 
% PULSESPACEDBARS
%
% Description:
%   Series of spaced-out bars
%
% Parent:
%   sara.protocols.spatial.Pulse
%
% Syntax:
%   obj = PulseSpacedBars(calibration, varargin)
%
% Properties:
%   barWidth                    Width of each bar in pixels
%   barSpacing                  Number of bars before beginning another bar
%   orientation                 'horizontal' or 'vertical'
%   seriesID                    Which stimulus in series (1-barSpacing)
%
% Derived properties:
%   numSpacedBars               Number of bars presented at once
%
% Notes:
%   The number of stimuli needed to cover field is determined by barSpacing
% -------------------------------------------------------------------------

    properties 
        seriesID                % Which stimulus in series (1-barSpacing)
        barWidth                % Width of each bar in pixels
        barSpacing              % Spacing between bars (in bars)
        orientation             % 'horizontal' or 'vertical'
    end

    properties (SetAccess = private)
        numBars                 % Number of bars presented at once
    end

    methods
        function obj = PulseSpacedBars(calibration, varargin)
            obj = obj@sara.protocols.spatial.Pulse(calibration, varargin{:});

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'SeriesID', 1, @isnumeric);
            addParameter(ip, 'BarSpacing', 8, @isnumeric);
            addParameter(ip, 'BarWidth', 2, @isnumeric);
            addParameter(ip, 'Orientation', 'vertical',... 
                @(x) ismember(x, {'vertical', 'horizontal'}));
            parse(ip, varargin{:});

            obj.seriesID = ip.Results.SeriesID;
            obj.barSpacing = ip.Results.BarSpacing;
            obj.barWidth = ip.Results.BarWidth;
            obj.orientation = ip.Results.Orientation;

            % Input checking
            assert(obj.seriesID > 0 & obj.seriesID <= obj.barSpacing,...
                'SeriesID must fall between 1 and barSpacing');

            % Derived properties
            if strcmp(obj.orientation, 'horizontal')
                obj.numBars = floor(obj.canvasSize(1) / obj.barWidth);
            else
                obj.numBars = floor(obj.canvasSize(2) / obj.barWidth);
            end
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(obj.canvasSize(1), ...
                obj.canvasSize(2), obj.totalSamples);   
            
            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            for i = 1:obj.totalTime
                if i > prePts && i <= prePts+stimPts
                    for j = 1:obj.barSpacing:obj.numBars
                        stim(:, (j-1)*obj.barWidth+1 : j*obj.barWidth, i) = obj.amplitude;
                    end
                end
            end

            if strcmp(obj.orientation, 'horizontal')
                stim = stim';
            end
        end

        function fName = getFileName(obj)
            fName = getFileName@sara.protocols.spatial.Pulse(obj);
            fName = [fName, '_', sprintf('spaced_bars_%upix_%uof%u',...
                obj.barWidth, obj.seriesID, obj.numBars)];
        end
    end
end 