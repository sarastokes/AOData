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
%   Devices                     container for Channel's devices
%
% Methods:
%   add(obj, device)
%   remove(obj, ID)
%   assignUUID(obj, uuid)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Devices                     aod.core.Device = aod.core.Device.empty()
    end

    methods
        function obj = Channel(name, varargin)
            % CHANNEL
            %
            % Description:
            %   
            % -------------------------------------------------------------
            obj = obj@aod.core.Entity(name, varargin{:});
        end
    end
    
    methods (Sealed)
        function out = get(obj, entityType, queries)
            % Search Epoch's child entities
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (described below in examples)
            %
            % Syntax:
            %   out = get(obj, entityType)
            %   out = get(obj, queries)   
            %
            % Inputs:
            %   entityType          char or aod.core.EntityTypes
            %       Child entity type to access (Device)
            %   queries             cell
            %       One or more queries within cells
            %
            % Notes:
            %   query specification is documented in aod.core.EntitySearch
            %
            % See Also:
            %   aod.core.EntitySearch
            % -------------------------------------------------------------

            import aod.core.EntityTypes

            entityType = EntityTypes.get(entityType);
            
            if entityType ~= EntityTypes.DEVICE 
                error('get:InvalidEntityType',...
                    'Only Devices can be searched from Channel');
            end

            if nargin > 2
                out = aod.core.EntitySearch.go(obj.Devices, queries);
            else
                out = obj.Devices;
            end
        end
    
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
        
        function remove(obj, varargin)
            % Remove an entity (device)
            %
            % Description:
            %   Remove a Device from the channel
            %
            % Syntax:
            %   remove(obj, ID)
            %   remove(obj, entityType, ID)
            %
            % Notes:
            %   entityType argument is optional as only Device can be  
            %   removed from a Channel 
            % -------------------------------------------------------------
            
            if nargin == 3
                entityType = aod.core.EntityTypes.get(varargin{1});
                if entityType ~= aod.core.EntityTypes.DEVICE
                    error('remove:InvalidEntityType', ...
                        'Only Device can be removed from Channel');
                end
                ID = varargin{2};
            elseif nargin == 2
                ID = varargin{1};
            end

            if isnumeric(ID)
                mustBeInteger(ID); mustBeInRange(ID, 1, numel(obj.Devices));
                obj.Devices(ID) = [];
            elseif istext(ID) && strcmpi(ID, 'all')
                obj.Devices = aod.core.Device.empty();
            else
                error('remove:InvalidID',...
                    'ID must be integer indices or "all"');
            end
        end
    end
end