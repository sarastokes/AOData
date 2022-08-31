classdef Stimulus < aod.core.Entity & matlab.mixin.Heterogeneous
% STIMULUS
%
% Description:
%   A stimulus presented during an Epoch
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
% 
% Constructor:
%   obj = aod.core.Stimulus(name, protocol)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Calibration

        protocolClass
        protocolName
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Epoch'};
    end
    
    methods
        function obj = Stimulus(name, protocol)
            obj = obj@aod.core.Entity(name);
            if nargin > 1
                obj.protocolClass = class(protocol);
                obj.setFile('Protocol', fileparts(protocol.getFileName()));
                [~, obj.protocolName, ~] = fileparts(protocol.getFileName());
                obj.getProtocolParameters(protocol);
            end
        end
    end

    methods (Sealed)
        function setCalibration(obj, calibration)
            assert(isSubclass(calibration, 'aod.core.Calibration'),...
                'calibration must be subclass of aod.core.Calibration');
            obj.Calibration = calibration;
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
            protocolFcn = str2func(obj.protocolName);
            protocol = protocolFcn(calibration, map2struct(obj.parameters));
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = obj.protocolName;
        end
        
        function sync(obj)
            if ~isempty(obj.Calibration)
                success = false;
                h = ancestor(obj, 'aod.core.Experiment');
                cal = h.getCalibration(class(obj.Calibration));
                if ~isempty(cal)
                    if cal.calibrationDate == obj.Calibration.calibrationDate
                        obj.setCalibration(cal);
                        success = true;
                    end
                end
                if ~success
                    warning("Stimulus:CalibrationSyncError",... 
                        "Protocol calibration could not be matched to an experiment calibration");
                end
            end
        end
    end

    methods (Sealed, Access = private)
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
