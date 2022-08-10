classdef MovingBar < sara.protocols.SpatialProtocol
% MOVINGBAR
%
% Description:
%   A bar that moves...
%
% Parent:
%   sara.protocols.SpatialProtocol
%
% Syntax:
%   obj = MovingBar(varargin);
%
% Properties:
%   direction
%   barWidth
%   barSpeed
%   useAperture
%   repeats
%
% Inherited properties:
%   See aod.builtin.protocols.StimulusProtocol
%
% Derived properties;
%   startFrames
% -------------------------------------------------------------------------

    properties
        direction           % Direction in degrees
        barWidth            % pixels
        barSpeed            % pixels/sec
        useAperture         % logical (default = true)
        numReps             % number of bar presentations (default = 1)
    end

    properties (SetAccess = private)
        startFrames
    end

    methods
        function obj = MovingBar(calibration, varargin)
            obj = obj@sara.protocols.SpatialProtocol(calibration, varargin{:});
            
            ip = inputParser();
            addParameter(ip, 'Direction', 0, @(x) x >= 0 & x <= 360);
            addParameter(ip, 'BarWidth', 20, @isnumeric);
            addParameter(ip, 'BarSpeed', 1, @isnumeric);
            addParameter(ip, 'UseAperture', true, @islogical);
            addParameter(ip, 'NumReps', 1, @(x) x > 0);
            parse(ip, varargin{:});

            obj.direction = ip.Results.Direction;
            obj.barWidth = ip.Results.BarWidth;
            obj.barSpeed = ip.Results.BarSpeed;
            obj.useAperture = ip.Results.UseAperture;
            obj.numReps = ip.Results.NumReps;

            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            obj.startFrames = [];
            for i = 1:obj.numReps
                obj.startFrames = cat(2, obj.startFrames,...
                    prePts + (i-1)*stimPts+1);
            end
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
            warning('Not yet implemented within ao-data-tools!');
        end

        function fName = getFileName(obj)
            if ~obj.useAperture
                apertureFlag = '_full_';
            else
                apertureFlag = '_';
            end
            fName = sprintf('moving_bar%s%udeg_%upix_%uv_%ut',...
                apertureFlag, obj.direction, obj.barWidth, obj.barSpeed, obj.totalTime);
        end
    end
    
    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (obj.numReps*obj.stimTime) + obj.tailTime;
        end
    end
end
