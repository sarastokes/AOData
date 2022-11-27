classdef System < aod.core.Entity & matlab.mixin.Heterogeneous
% SYSTEM
%
% Description:
%    A configuration of the AO imaging system 
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = System(name)
%
% Properties:
%   Channels
%
% Methods:
%   add(obj, channel)
%   removeChannel(obj, ID)
%   clearChannels(obj)
%   clearAllChannels(obj)
%   clearAllDevices(obj)
% -------------------------------------------------------------------------
    
    properties (SetAccess = protected)
        Channels            = aod.core.Channel.empty();
    end
    
    methods
        function obj = System(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
        end      
    end
    
    methods (Sealed)
        function add(obj, channel)
            % ADD
            %
            % Syntax:
            %   add(obj, channel)
            % -------------------------------------------------------------
            assert(isSubclass(channel, 'aod.core.Channel'),...
                'Invalid type: must be a subclass of aod.core.Channel');

            channel.setParent(obj);
            obj.Channels = cat(1, obj.Channels, channel);
        end

        function removeChannel(obj, ID)
            % REMOVECHANNEL
            %
            % Description:
            %   Remove the specfied channel
            %
            % Syntax:
            %   removeChannel(obj, ID)
            % -------------------------------------------------------------
            if isempty(obj.Channels)
                error("removeChannel:NoChannelsPresent",...
                    "Cannot remove channel as no channels are present");
            end
            assert(ID <= numel(obj.Channels),... 
                'Invalid ID %u, must be between 1-%u', numel(obj.Channels));
            obj.Channels(ID) = [];
        end
        
        function clearChannels(obj)
            % CLEARCHANNELS
            %
            % Description:
            %   Clear all channels
            %
            % Syntax:
            %   clearChannels(obj)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                arrayfun(@(x) clearChannels(x), obj);
                return
            end

            obj.Channels = [];
        end

        function devices = getAllDevices(obj)
            % GETALLDEVICES
            %
            % Description:
            %   Get devices within all channels
            %
            % Syntax:
            %   devices = getAllDevices(obj)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                devices = arrayfun(@(x) getAllDevices(x), obj);
                return
            end
            devices = vertcat(obj.Channels.Devices);
        end

        function clearAllDevices(obj)
            % CLEARALLDEVICES
            %
            % Description:
            %   Clear all the devices in all child channels
            %
            % Syntax:
            %   clearAllDevices(obj)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                arrayfun(@(x) clearAllDevices(x), obj);
                return
            end

            if isempty(obj.Channels)
                return
            end

            for i = 1:numel(obj.Channels)
                obj.Channels(i).clearDevices();
            end
        end
    end
    
    % Overloaded methods
    methods (Access = protected)
        function value = getLabel(obj)
            value = [obj.Name, 'System'];
        end
    end
end