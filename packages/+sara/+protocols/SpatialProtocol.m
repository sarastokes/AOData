classdef (Abstract) SpatialProtocol < aod.builtin.protocols.StimulusProtocol
% SPATIALPROTOCOL (abstract)
%
% Description:
%   Spatial stimuli presented with a laser through the scanning system
%
% Properties:
%   baseIntensity (0-1)     baseline intensity of stimulus
%   contrast (0-1)          scaling applied during stimTime
%                           - computed as contrast if baseIntensity > 0
%                           - computed as intensity if baseIntensity = 0
%
% A stimulus is written by the following logic:
%   1. GENERATE: Calculates normalized stimulus values (0-1)
%   2. MAPTOSTIMULATOR: Uses calibrations to convert to uint8
%   3. WRITESTIM: Outputs the file used by imaging software
% Each method will call the prior steps
% You can either provide a file name to writeStim or overwrite getFileName
%
% Abstract methods (from aod.util.Protocol, implement in subclasses):
%   stim = obj.generate()
%
% Methods (inherited, implemented by subclasses):
%   fName = getFileName(obj)
%   stim = mapToStimulator(obj)
%   writeStim(obj, fName)
% Methods (optional):
%   trace = temporalTrace(obj)
%   plotTemporalTrace(obj)
% -------------------------------------------------------------------------
    properties (SetAccess = protected)
        % Shared by all Protocols
        sampleRate = 25
        stimRate = 25
    end

    properties (Hidden, SetAccess = private)
        canvasSize = [256, 256]        % pixels
    end

    methods
        function obj = SpatialProtocol(calibration, varargin)
            obj = obj@aod.builtin.protocols.StimulusProtocol(calibration, varargin{:});
        end

        function fName = getFileName(obj) %#ok<MANU> 
            % GETFILENAME
            %
            % Description:
            %   Specifies a default file name. Overwrite in subclasses
            %
            % Syntax:
            %   fName = getFileName(obj)
            % -------------------------------------------------------------
            fName = 'SpatialStimulus';
        end
        
        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(obj.canvasSize(1), ...
                obj.canvasSize(2), obj.totalTime);
        end

        function stim = mapToStimulator(obj)
            % MAPTOSTIMULATOR
            %
            % Description:
            %   Apply nonlinearity and change to uint8
            %
            % Syntax:
            %   stim = mapToStimulator(obj)
            % -------------------------------------------------------------
            assert(isSubclass(obj.Calibration, 'sara.calibrations.TopticaNonlinearity'),...
                'SpatialProtocol/mapToStimulator: requires TopticaNonlinearity calibration');

            stim = obj.generate();
            lookupFit = fit(obj.Calibration.Data.Value, obj.Calibration.Data.Power,...
                'cubicinterp');
            lookupTable = lookupFit(0:255);

            powerRange = max(obj.Calibration.Data.Power) - min(obj.Calibration.Data.Power);
            powerStim = powerRange * stim + min(obj.Calibration.Data.Power);

            [x, y, t] = size(powerStim);
            powerStim = powerStim(:);
            stim = zeros(size(powerStim));

            values = unique(powerStim);
            if numel(values) < 10
                % If theres just a few unique values, don't run point by point
                for i = 1:numel(values)
                    stim(powerStim == values(i)) = sara.util.findclosest(lookupTable, values(i));
                end
            else
                for i = 1:numel(powerStim)
                    stim(i) = sara.util.findclosest(lookupTable, powerStim(i));
                end
            end

            stim = uint8(stim - 1);
            stim = reshape(stim, [x y t]);

            % Rotate counter-clockwise (1P system applies clockwise rotation)
            stim = rot90(stim);
        end

        function writeStim(obj, fName)
            % WRITESTIM
            % 
            % Syntax:
            %   writeStim(obj, fName)
            % -------------------------------------------------------------
            if nargin < 2
                fName = obj.getFileName();
            end

            [~, ~, ext] = fileparts(fName);
            if isempty(ext)
                fName = [fName, '.avi'];
            else
                assert(contains(ext, 'avi'), 'File extension must be AVI');
            end

            stim = obj.mapToStimulator();
            v = VideoWriter(fName, 'Grayscale AVI');
            v.FrameRate = 25;
            open(v)
            for i = 1:size(stim)
                writeVideo(v, stim(:,:,i));
            end
            close(v);
            fprintf('Finished writing %s\n', fName);
        end
    end

    methods
        function trace = temporalTrace(obj)
            % TEMPORALTRACE
            %
            % Description:
            %   Vector representation of stimulus over time. Default shows
            %   base intensity and a step to contrast value during stim
            %   time. Subclass to tailor for other stimuli. This is useful
            %   for getting a 1D temporal representation of a 3D spatial
            %   stimulus for plotting
            %
            % Syntax:
            %   trace = temporalTrace(obj);
            % -------------------------------------------------------------
            trace = obj.baseIntensity + zeros(1, obj.totalPoints);
            if obj.stimTime > 0
                prePts = obj.sec2pts(obj.preTime);
                stimPts = obj.sec2pts(obj.stimTime);
                trace(prePts+1:prePts+stimPts) = obj.amplitude + obj.baseIntensity;
            end
        end
        
        function h = plotTemporalTrace(obj, trace)
            % PLOTTEMPORALTRACE
            %   
            % Description:
            %   Create a quick plot of the protocol's temporal trace
            %
            % Syntax:
            %   h = plotTemporalTrace(obj, trace)
            %
            % Output:
            %   h               handle to line plotting stimulus trace
            % -------------------------------------------------------------
            if nargin < 2
                trace = obj.temporalTrace();
            end

            ax = axes('Parent', figure()); hold on;
            h = plot(ax, obj.pts2sec(1:numel(trace)), trace, 'LineWidth', 1);
            title(ax, class(obj));
            xlabel('Time (sec)');
            ylabel('Normalized');
            axis(ax, 'tight');
            ylim(ax, [0 1]);
            grid(ax, 'on');
        end
    end

    methods (Access = protected)
        function stim = initStimulus(obj)
            stim = obj.baseIntensity + zeros(obj.canvasSize(1), obj.canvasSize(2), obj.totalPoints);   
        end
    end
end