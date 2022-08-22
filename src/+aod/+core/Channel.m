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
%   obj = Channel(parent, channelName, varargin)
%
% Parameters:
%   DataFolder                  char, folder for the channel's data
%
% Properties:
%   Name                        char, channel name
%   Devices                     container for all devices in channel
%   channelParameters           aod.core.Parameters
%
% Methods:
%   assignUUID(obj, uuid)
%   addDevice(obj, device)
%   removeDevice(obj, ID)
%   clearDevices(obj)
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        Name                        char
        Devices                     aod.core.Device
        % channelParameters           = aod.core.Parameters
    end
    
    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.System'};
        % parameterPropertyName = 'channelParameters';
    end

    methods
        function obj = Channel(parent, channelName, varargin)
            obj = obj@aod.core.Entity(parent);
            obj.setName(channelName);

            ip = aod.util.InputParser();
            addParameter(ip, 'DataFolder', '', @ischar);
            parse(ip, varargin{:});

            obj.setParam(ip.Results);
        end
    end
    
    methods (Sealed)
        function setName(obj, channelName)
            % SETNAME
            %
            % Description:
            %   Assign channel name
            %
            % Syntax:
            %   setName(obj, channelName)
            % -------------------------------------------------------------
            obj.Name = channelName;
        end

        function addDevice(obj, device)
            % ADDDEVICE
            %
            % Syntax:
            %   addDevice(obj, device)
            % -------------------------------------------------------------
            assert(isSubclass(device, 'aod.core.Device'),...
                'Must be subclass of aod.core.Device');
            device.setParent(obj);
            obj.Devices = cat(1, obj.Devices, device);
        end
        
        function removeDevice(obj, deviceID)
            % REMOVEDEVICES
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
            % Syntax:
            %   clearDevices(obj)
            % -------------------------------------------------------------
            obj.Devices = [];
        end

        function setDataFolder(obj, folderName)
            % SETDATAFOLDER
            %
            % Syntax:
            %   setDataFolder(obj, folderName)
            % -------------------------------------------------------------
            assert(istext(folderName), 'Data folder must be string or char');
            obj.setParam('DataFolder', folderName);
        end

        function assignUUID(obj, UUID)
            % ASSIGNUUID
            %
            % Description:
            %   The same channels may be used over multiple experiments and
            %   should share UUIDs. This function provides public access
            %   to aod.core.Entity's setUUID function to facilitate hard-
            %   coded UUIDs for common sources
            %
            % Syntax:
            %   obj.assignUUID(UUID)
            %
            % See also:
            %   aod.util.generateUUID
            % -------------------------------------------------------------
            obj.setUUID(UUID);
        end
    end

    % Overwritten methods
    methods (Access = protected)
        function value = getLabel(obj)
            value = [obj.Name, 'Channel'];
        end
    end
end