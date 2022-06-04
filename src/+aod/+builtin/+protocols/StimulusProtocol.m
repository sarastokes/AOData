classdef (Abstract) StimulusProtocol < aod.core.Protocol
% STIMULUSPROTOCOL
%
% Description:
%   A protocol presenting a visual stimulus
%
% Properties:
%   baseIntensity (0-1)     baseline intensity of stimulus
%   contrast (0-1)          scaling applied during stimTime
%                           - computed as contrast if baseIntensity > 0
%                           - computed as intensity if baseIntensity = 0
%
% -------------------------------------------------------------------------
    properties
        baseIntensity
        contrast
    end

    properties (Dependent)
        amplitude
    end

    methods
        function obj = StimulusProtocol(varargin)
            obj = obj@aod.core.Protocol(varargin{:});

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
            fName = 'Stimulus';
        end
    end
end

