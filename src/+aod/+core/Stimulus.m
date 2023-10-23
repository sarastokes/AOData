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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetObservable, SetAccess = {?aod.core.Entity})
        Calibration                 {aod.util.mustBeEntityType(Calibration, 'Calibration')} = aod.core.Calibration.empty()

        protocolClass               string = string.empty()
        protocolName                string = string.empty()
        DateProtocolCreated         datetime = datetime.empty()
    end

    methods
        function obj = Stimulus(name, protocol, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});

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
            if isempty(calibration)
                obj.Calibration = aod.core.Calibration.empty();
            end
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
            arguments
                obj
                protocol        {mustBeA(protocol, 'aod.common.Protocol')}
            end

            obj.protocolClass = class(protocol);
            obj.DateProtocolCreated = protocol.dateCreated;
            obj.setFile('Protocol', fileparts(protocol.getFileName()));
            [~, obj.protocolName, ~] = fileparts(protocol.getFileName());
            obj.getProtocolParameters(protocol);
        end

        function protocol = getProtocol(obj, calibration)
            % Regenerate the protocol
            %
            % Description:
            %   Use properties to regenerate the Protocol object
            %
            % Syntax:
            %   protocol = getProtocol(obj)
            % -------------------------------------------------------------
            if isempty(obj.protocolName)
                error("getProtocol:ProtocolNotSet",...
                    "Stimulus needs protocol for this function");
            end
            if nargin < 2
                calibration = [];
            end
            protocolFcn = str2func(obj.protocolClass);
            protocol = protocolFcn(calibration, map2struct(obj.attributes));
        end
    end


    methods (Sealed, Access = protected)
        function getProtocolParameters(obj, protocol)
            % Extract attributes from protocol
            %
            % Description:
            %   Extract calibration and attributes, save to Stimulus
            %
            % Syntax:
            %   getProtocolParameters(obj, protocol)
            % -------------------------------------------------------------
            mc = metaclass(protocol);
            for i = 1:numel(mc.PropertyList)
                if strcmp(mc.PropertyList(i).GetAccess, 'public')
                    propName = mc.PropertyList(i).Name;
                    if isnumeric(propName) && isnan(propName)
                        continue
                    end
                    if strcmpi(propName, 'Calibration')
                        obj.setCalibration(protocol.(propName));
                    elseif strcmpi(propName, 'dateCreated')
                        obj.DateProtocolCreated = protocol.(propName);
                    else
                        obj.setAttr(propName, protocol.(propName));
                    end
                end
            end
        end
    end

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Entity(value);

            value.set("Calibration",...
                "Class", ["aod.core.Calibration", "aod.persistent.Calibration"],...
                "Size", "(1,1)", "Default", aod.core.Calibration.empty(),...
                "Description", "The calibration used to design the stimulus");
            value.set("protocolName",...
                "Class", "string", "Size", "(1,1)",...
                "Description", "The name of the protocol used.");
        end
    end
end
