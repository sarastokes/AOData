classdef (Abstract) VisualStimulus < aod.core.Stimulus 
% VISUALSTIMULUS
%
% Inherited properties:
%   stimParameters
%
% Inherited methods:
%   addParameter(obj, varargin)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        protocolName
        defaultProtocolFile     % Used for display name
    end

    methods
        function obj = VisualStimulus(parent, protocol)
            obj = obj@aod.core.Stimulus(parent);
            if nargin > 1
                obj.protocolName = class(protocol);
                obj.getProtocolParameters(protocol);
                [~, obj.defaultProtocolFile, ~] = fileparts(protocol.getFileName());
            end
        end

        function protocol = getProtocol(obj, calibration)
            % GETPROTOCOL
            %
            % Description:
            %   Use properties to regenerate the Protocol object
            %
            % Syntax:
            %   protocol = getProtocol(obj)
            %
            % TODO: Automate calibration identification
            % -------------------------------------------------------------
            protocolFcn = str2func(obj.protocolName);
            protocol = protocolFcn(calibration, map2struct(obj.stimParameters));
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = [];
            txt = strsplit(obj.defaultProtocolFile, '_');
            for i = 1:numel(txt)
                value = [value, capitalize(txt{i})]; %#ok<AGROW> 
            end
        end
    end

    methods (Access = private)
        function getProtocolParameters(obj, protocol)
            % GETPROTOCOLPARAMETERS
            %
            % Description:
            %   Move protocol properties to stimulusProperties
            % -------------------------------------------------------------
            mc = metaclass(protocol);
            for i = 1:numel(mc.PropertyList)
                if strcmp(mc.PropertyList(i).GetAccess, 'public')
                    if isnumeric(mc.PropertyList(i).Name) && isnan(mc.PropertyList(i).Name)
                        continue
                    end
                    obj.addParameter(mc.PropertyList(i).Name,...
                        protocol.(mc.PropertyList(i).Name));
                end
            end
        end
    end
end