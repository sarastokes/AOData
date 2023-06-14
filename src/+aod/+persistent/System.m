classdef System < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% A System in an HDF5 file
%
% Description:
%   Represents a persisted System in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.System(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.System

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ChannelsContainer
    end

    methods 
        function obj = System(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed)
        function tf = has(obj, entityType, varargin)
            % Search Systems's child entities and return if matches exist
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria and return whether matches exist
            %
            % Syntax:
            %   tf = has(obj, entityType, varargin)
            %
            % Inputs:
            %   entityType          char or aod.common.EntityTypes
            % Optional inputs:
            %   One or more cells containing queries
            %
            % See also:
            %   aod.persistent.System/get
            % -------------------------------------------------------------

            out = obj.get(entityType, varargin{:});
            tf = ~isempty(out);
        end

        function out = get(obj, entityType, varargin)
            % Get System's channels and devices
            %
            % Description:
            %   Return all the channels or devices within the system or 
            %   just the ones that match the one or more queries
            %
            % Syntax:
            %   out = get(obj, entityType, varargin)
            %
            % Inputs:
            %   entityType          char or aod.common.EntityTypes
            % -------------------------------------------------------------
        
            import aod.common.EntityTypes 

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
                out = aod.common.EntitySearch.go(group, varargin{:});
            else
                out = group;
            end
        end

        function add(obj, channel)
            % ADD
            % 
            % Description:
            %   Add a Channel to the Experiment and the HDF5 file
            %
            % Syntax:
            %   add(obj, channel)            
            %
            % Examples:
            %   channel = aod.core.Channel('MyChannel');
            %   system.add(channel)
            % -------------------------------------------------------------
            arguments
                obj
                channel             {mustBeA(channel, 'aod.core.Channel')}
            end

            channel.setParent(obj);
            obj.addEntity(channel);
        end
    end

    methods 
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
                devices = aod.persistent.Device.empty();
            else
                devices = vertcat(obj.Channels.Devices);
            end
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            % Add user-defined datasets and links
            obj.populateDatasetsAsDynProps();
            obj.populateLinksAsDynProps();
        end

        function populateContainers(obj)
            obj.ChannelsContainer = obj.loadContainer('Channels');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Channels(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj.ChannelsContainer(idx));
            end
        end
    end
end