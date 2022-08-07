classdef Channel < aod.core.Entity & matlab.mixin.Heterogeneous
% CHANNEL
%
% Description:
%   Represents a single channel within a system configuration
%
% Parent:
%   aod.core.Entity
%   matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Channel(parent)
%
% Methods:
%   addParameter(obj, varargin)
%   assignUUID(obj, uuid)
%   addDevice(obj, device)
%   removeDevice(obj, ID)
%   clearDevices(obj)
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        dataFolder
        Devices                         = aod.core.Device.empty()
        channelParameters               % aod.core.Parameters
    end
    
    methods
        function obj = Channel(parent)
            obj.allowableParentTypes = {'aod.core.System', 'aod.core.Empty'};
            if nargin > 0
                obj.setParent(parent);
            end
            obj.channelParameters = aod.core.Parameters;
        end
    end
    
    methods (Sealed)
        function addDevice(obj, device)
            assert(isSubclass(device, 'aod.core.Device'),...
                'Must be subclass of aod.core.Device');
            obj.Devices = cat(1, obj.Devices, device);
        end
        
        function removeDevice(obj, deviceID)
            assert(deviceID <= numel(obj.Devices), 'Invalid Device number');
            obj.Devices(deviceID) = [];
        end
        
        function clearDevices(obj)
            obj.Devices = [];
        end

        function setDataFolder(obj, folderName)
            assert(istext(folderName), 'Data folder must be string or char');
            obj.dataFolder = folderName;
        end

        function addParameter(obj, varargin)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, value)
            %   obj.addParameter(paramName, value, paramName, value)
            %   obj.addParameter(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    obj.sourceParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.sourceParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
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
            %   generateUUID
            % -------------------------------------------------------------
            obj.setUUID(UUID);
        end
    end
end