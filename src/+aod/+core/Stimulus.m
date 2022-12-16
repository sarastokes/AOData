classdef Stimulus < aod.core.Entity & matlab.mixin.Heterogeneous
% A stimulus presented during an Epoch
%
% Description:
%   A stimulus presented during an Epoch
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
% 
% Constructor:
%   obj = aod.core.Stimulus(name)
%   obj = aod.core.Stimulus(name, protocol)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Calibration

        protocolClass
        protocolName
    end
    
    methods
        function obj = Stimulus(name, protocol)
            obj = obj@aod.core.Entity(name);
            % TODO handle with inputParser optional argument
            if nargin > 1 && ~isempty(protocol)
                obj.setProtocol(protocol);
            end
        end
    end

    methods (Sealed)
        function setCalibration(obj, calibration)
            % SETCALIBRATION
            %
            % Description:
            %   Set the calibration used in the experiment, if not already
            %   defined by the protocol.
            %
            % Syntax:
            %   setCalibration(obj, calibration)
            % -------------------------------------------------------------
            assert(isSubclass(calibration, 'aod.core.Calibration'),...
                'calibration must be subclass of aod.core.Calibration');

            obj.Calibration = calibration;
        end

        function setProtocol(obj, protocol)
            % SETPROTOCOL
            %
            % Description:
            %   Use stored protocol properties to regenerate the Protocol
            %
            % Syntax:
            %   setProtocol(obj, protocol)
            % -------------------------------------------------------------
            assert(isSubclass(protocol, 'aod.core.Protocol'),...
                'Protocol must be subclass of aod.core.Protocol');

            obj.protocolClass = class(protocol);
            obj.setFile('Protocol', fileparts(protocol.getFileName()));
            [~, obj.protocolName, ~] = fileparts(protocol.getFileName());
            obj.getProtocolParameters(protocol);
        end

        function protocol = getProtocol(obj, calibration)
            % GETPROTOCOL
            %
            % Description:
            %   Use properties to regenerate the Protocol object
            %
            % Syntax:
            %   protocol = getProtocol(obj)
            % -------------------------------------------------------------
            if isempty(obj.protocolName)
                error("Stimulus:ProtocolNotSet",...
                    "Stimulus needs protocol for this function");
            end
            protocolFcn = str2func(obj.protocolName);
            protocol = protocolFcn(calibration, map2struct(obj.parameters));
        end
    end


    methods (Sealed, Access = protected)
        function getProtocolParameters(obj, protocol)
            % GETPROTOCOLPARAMETERS
            %
            % Description:
            %   Extract calibration and parameters, save to Stimulus
            %
            % Syntax:
            %   getProtocolParameters(obj, protocol)
            % -------------------------------------------------------------
            mc = metaclass(protocol);
            for i = 1:numel(mc.PropertyList)
                if strcmp(mc.PropertyList(i).GetAccess, 'public')
                    if isnumeric(mc.PropertyList(i).Name) && isnan(mc.PropertyList(i).Name)
                        continue
                    end
                    if strcmpi(mc.PropertyList(i).Name, 'Calibration')
                        obj.setCalibration(protocol.(mc.PropertyList(i).Name));
                    else
                        obj.setParam(mc.PropertyList(i).Name,...
                            protocol.(mc.PropertyList(i).Name));
                    end
                end
            end
        end
    end
end
