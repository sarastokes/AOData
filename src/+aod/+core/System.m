classdef System < aod.core.Entity & matlab.mixin.Heterogeneous
% A configuration of an AO imaging system
%
% Description:
%    A configuration of the AO imaging system 
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.System(name)
%
% Properties:
%   Channels
%
% Methods:
%   add(obj, channel)
%   remove(obj, ID), remove(obj, entityType, ID)
%   clearAllDevices(obj)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    properties (SetAccess = protected)
        Channels           aod.core.Channel = aod.core.Channel.empty();
    end
    
    methods
        function obj = System(name, varargin)
            if nargin == 0
                name = [];
            end
            obj = obj@aod.core.Entity(name, varargin{:});
        end      
    end
    
    methods (Sealed)
        function out = get(obj, entityType, queries)
            import aod.core.EntityTypes
            entityType = EntityTypes.get(entityType);

            switch entityType
                case EntityTypes.CHANNEL 
                    group = obj.Channels;
                case EntityTypes.DEVICE 
                    group = obj.getChannelDevices();
                otherwise
                    error('get:InvalidEntityType',...
                        'Only Channel and Device can be searched from System');
            end
            
            if nargin > 2
                out = aod.core.EntitySearch.go(group, queries);
            else
                out = group;
            end
        end

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

        function remove(obj, varargin)
            % Remove a channel
            %
            % Description:
            %   Remove the specfied channel
            %
            % Syntax:
            %   remove(obj, ID)
            %   remove(obj, entityType, ID)
            %
            % Notes:
            %   Because System has only one child entity, remove() can be 
            %   called without specifying the entityType (assumed to be 
            %   Channel). It will also work if entityType is specified
            % -------------------------------------------------------------

            if nargin == 2
                ID = varargin{1};
            elseif nargin == 3
                entityType = aod.core.EntityTypes.get(varargin{1});
                assert(entityType == aod.core.EntityTypes.CHANNEL,...
                    'Only Channels can be removed from System');
                ID = varargin{2};
            end
            
            if ~isscalar(obj)
                arrayfun(@(x) remove(x, ID), obj);
                return
            end

            if isnumeric(ID)
                mustBeInteger(ID); mustBeInRange(ID, 1, numel(obj.Channels));
                obj.Channels(ID) = [];
            elseif istext(ID) && strcmpi(ID, 'all')
                obj.Channels = aod.core.Channel.empty();
            else
                error('remove:InvalidID', 'ID must be integer indices or "all"');
            end
        end

        function devices = getChannelDevices(obj)
            % Get all Devices within System's Channels
            %
            % Description:
            %   Get devices within all channels
            %
            % Syntax:
            %   devices = getChannelDevices(obj)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                devices = uncell(aod.util.arrayfun(@(x) getChannelDevices(x), obj));
                return
            end

            if isempty(obj.Channels)
                devices = aod.core.Device.empty();
            else
                devices = vertcat(obj.Channels.Devices);
            end
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
                remove(obj.Channels(i), 'Device', 'all');
            end
        end
    end
end