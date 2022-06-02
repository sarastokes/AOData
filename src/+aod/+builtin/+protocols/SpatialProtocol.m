classdef (Abstract) SpatialProtocol < aod.core.Protocol
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
%   2. MAPTOLEDS: Uses calibrations to convert to uint8
%   3. WRITESTIM: Outputs the file used by imaging software
% Each method will call the prior steps
% -------------------------------------------------------------------------
    properties
        baseIntensity
        contrast
    end

    properties (Dependent, Access = protected)
        amplitude           % Intensity/contrast depending on baseIntensity
        totalFrames         % Total frames in stimulus presentation
    end

    properties (Hidden, Access = protected)
        canvasSize = [256, 256];       % pixels
    end

    methods
        function obj = SpatialProtocol(stimTime, varargin)
            obj = obj@aod.core.Protocol(stimTime, varargin{:});

            % Shared by all SpatialProtocols
            obj.sampleRate = 25;
            obj.stimRate = 25;

            % Input parsing
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'BaseIntensity', 0, @isnumeric);
            addParameter(ip, 'Contrast', 1, @isnumeric);
            parse(ip, varargin{:});

            obj.baseIntensity = ip.Results.BaseIntensity;
            obj.contrast = ip.Results.Contrast;
        end

        function value = get.totalFrames(obj)
            value = obj.preFrames + obj.stimFrames + obj.tailFrames;
        end

        function value = get.amplitude(obj)
            if obj.baseIntensity == 0
                value = obj.contrast;
            else
                value = obj.contrast * obj.baseIntensity;
            end
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

        function stim = mapToLaser(obj)
            % MAPTOLASER
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
            stim = obj.mapToLaser();
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