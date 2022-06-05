classdef (Abstract) SpatialProtocol < aod.builtin.protocols.StimulusProtocol
% SPATIALPROTOCOL
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
% Abstract methods (from aod.core.Protocol, implement in subclasses):
%   stim = obj.generate()
%
% Methods:
%   fName = getFileName(obj)
%   stim = mapToLaser(obj)
%   writeStim(obj, fName)
% -------------------------------------------------------------------------
    properties (SetAccess = protected)
        % Shared by all Spatial Protocols
        sampleRate = 25;
        stimRate = 25;
    end

    properties (Hidden, SetAccess = private)
        canvasSize = [256, 256];       % pixels
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

        function trace = temporalTrace(obj)
            % TEMPORALTRACE
            %
            % Description:
            %   Vector representation of stimulus over time. Default shows
            %   base intensity and a step to contrast value during stim
            %   time. Subclass to tailor for other stimuli.
            %
            % Syntax:
            %   trace = temporalTrace(obj);
            % -------------------------------------------------------------
            trace = obj.baseIntensity + zeros(1, obj.totalTime);
            if obj.stimTime > 0
                prePts = obj.sec2pts(obj.preTime);
                stimPts = obj.sec2pts(obj.stimTime);
                trace(prePts+1:prePts+stimPts) = obj.amplitude;
            end
        end

        function stim = mapToStimulator(obj)
            % MAPTOSTIMULATOR
            %
            % Description:
            %   Apply nonlinearity and change to uint8
            %
            % Syntax:
            %   stim = mapToLaser(obj)
            % -------------------------------------------------------------
            stim = obj.generate();
            stim = applySystemNonlinearity3d(stim);
        end

        function writeStim(obj, fName)
            % WRITESTIM
            % 
            % Syntax:
            %   writeStim(obj, fName)
            % -------------------------------------------------------------
            if nargin < 2
                fName = obj.getFileName();
            else
                assert(endsWith(fName, '.avi'), 'Filename must end with .avi');
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
end