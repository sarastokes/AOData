classdef Channel < aod.core.Entity & matlab.mixin.Heterogeneous
% CHANNEL
%
% Description:
%   Represents a single channel within a system configuration
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Channel(name, varargin)
%
% Properties:
%   Devices                     container for all devices in channel
%
% Methods:
%   add(obj, device)
%   removeDevice(obj, ID)
%   clearDevices(obj)
%   assignUUID(obj, uuid)
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        Devices                     aod.core.Device
    end

    methods
        function obj = Channel(name)
            % CHANNEL
            %
            % Description:
            %   
            % -------------------------------------------------------------
            obj = obj@aod.core.Entity(name);
        end
    end
    
    methods (Sealed)
        function add(obj, device)
            % ADD
            %
            % Description:
            %   Add a Device to the Channel
            %
            % Syntax:
            %   add(obj, device)
            % -------------------------------------------------------------
            arguments
                obj
                device          {mustBeA(device, 'aod.core.Device')}
            end

            if ~isscalar(device)
                arrayfun(@(x) add(obj, x), device);
                return
            end
            
            device.setParent(obj);
            obj.Devices = cat(1, obj.Devices, device);
        end
        
        function removeDevice(obj, deviceID)
            % REMOVEDEVICES
            %
            % Description:
            %   Remove a Device from the channel
            %
            % Syntax:
            %   removeDevice(obj, deviceID)
            % -------------------------------------------------------------
            assert(deviceID <= numel(obj.Devices), 'Invalid Device number');
            obj.Devices(deviceID) = [];
        end
        
        function clearDevices(obj)
            % CLEARDEVICES
            %
            % Description:
            %   Clear all Devices from the Channel
            %
            % Syntax:
            %   clearDevices(obj)
            % -------------------------------------------------------------
            obj.Devices = [];
        end
    end

    % Overwritten methods
    methods (Access = protected)
        function value = getLabel(obj)
            value = [obj.Name, 'Channel'];
        end
    end
end