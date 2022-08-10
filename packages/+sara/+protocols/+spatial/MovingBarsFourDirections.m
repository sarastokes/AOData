classdef MovingBarsFourDirections < sara.protocols.SpatialProtocol
% MOVINGBARFOURDIRECTIONS
%
% Description:
%   A series of 4 moving bars in cardinal or diagonal directions
%
% Properties:
%   stimTime    time window for each bar presentation to occur
% -------------------------------------------------------------------------
    properties
        directionClass      % 'cardinal' or 'diagonal'
        barWidth            % pixels
        barSpeed            % pixels/sec
        useAperture         % logical (default = true)
    end

    properties (SetAccess = private)
        directions 
        startFrames
    end

    methods
        function obj = MovingBarsFourDirections(calibration, varargin)
            obj = obj@sara.protocols.SpatialProtocol(calibration, varargin{:});

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'DirectionClass', 'cardinal',... 
                @(x)ismember(x, {'cardinal', 'diagonal'}));
            addParameter(ip, 'BarWidth', 20, @isnumeric);
            addParameter(ip, 'BarSpeed', 1, @isnumeric);
            addParameter(ip, 'UseAperture', true, @islogical);
            parse(ip, varargin{:});

            obj.directionClass = ip.Results.DirectionClass;
            obj.barWidth = ip.Results.BarWidth;
            obj.barSpeed = ip.Results.BarSpeed;
            obj.useAperture = ip.Results.UseAperture;

            % Derived properties
            if strcmp(obj.directionClass, 'cardinal')
                obj.directions = [0, 90, 180, 270];
            else
                obj.directions = [45, 135, 225, 315];
            end

            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            obj.startFrames = prePts + [1, stimPts+1, (2*stimPts)+1, (3*stimPts)+1];
        end
    end

    methods
        function trace = temporalTrace(obj)
            % TEMPORALTRACE
            %
            % Description:
            %   Tracks bar location over time
            % -------------------------------------------------------------
            trace = zeros(1, obj.totalSamples);
            if obj.useAperture || strcmp(obj.directionClass, 'cardinal')
                barPts = min(obj.canvasSize) + obj.barWidth;
            else
                barPts = sqrt(2) * min(obj.canvasSize) + obj.barWidth;
            end
            for i = 1:4
                trace(obj.startFrames(i):obj.startFrames(i)+barPts-1) = 1:numel(barPts);
            end
        end

        function stim = generate(obj)
            warning('Not yet implemented!');
            stim = obj.baseIntensity + zeros(obj.totalSamples);
            stim(prePts+1:(stimPts*4)) = obj.amplitude;
        end

        function fName = getFileName(obj)
            if ~obj.useAperture
                apertureFlag = '_full_';
            else
                apertureFlag = '_';
            end
            fName = sprintf('moving_bar%s%udeg_%upix_%uv_%ut.txt',...
                apertureFlag, obj.directions, obj.barWidth, obj.barSpeed, obj.totalTime);
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (4*obj.stimTime) + obj.tailTime;
        end
    end
end 