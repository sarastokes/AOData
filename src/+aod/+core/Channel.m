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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % Container for the Channel's Devices
        Devices         aod.core.Device = aod.core.Device.empty()
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
        function tf = has(obj, varargin)
            % Search Channel's child entities and return if matches exist
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria and return whether matches exist
            %
            % Syntax:
            %   tf = has(obj, varargin)
            %
            % Inputs:
            %   Identical to aod.core.Channel.get()
            %
            % See also:
            %   aod.core.Channel/get
            % -------------------------------------------------------------
            out = obj.get(varargin{:});
            tf = ~isempty(out);
        end

        function out = get(obj, varargin)
            % Search Channel's child entities
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
            %   entityType          char or aod.common.EntityTypes
            %       Child entity type to access (Device)
            %   queries             cell
            %       One or more queries within cells
            %
            % Notes:
            %   - Queries are documented in aod.common.EntitySearch
            %
            % See Also:
            %   aod.common.EntitySearch
            % -------------------------------------------------------------

            import aod.common.EntityTypes

            try
                entityType = EntityTypes.get(varargin{1}); 
                startIdx = 2;
            catch 
                startIdx = 1;
            end

            % If entity type provided, make sure it's valid
            if startIdx == 2 && entityType ~= EntityTypes.DEVICE 
                error('get:InvalidEntityType',...
                    'Only Devices can be searched from Channel');
            end

            if nargin > 2
                out = aod.common.EntitySearch.go(obj.Devices,... 
                    varargin{startIdx:end});
            else
                out = obj.Devices;
            end
        end
    
        function add(obj, device)
            % Add a Device to the Channel
            %
            % Syntax:
            %   add(obj, device)
            %
            % Examples:
            %   channel = aod.core.Channel('MyChannel');
            %   device = aod.core.Device('MyDevice');
            %   channel.add(device)
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
            % Remove a Device from the Channel
            %
            % Syntax:
            %   remove(obj, varargin)
            %   remove(obj, entityType, varargin)
            %
            % Notes:
            %   - entityType argument is optional as only Device can be  
            %     removed from a Channel 
            % -------------------------------------------------------------
            
            if nargin == 3
                entityType = aod.common.EntityTypes.get(varargin{1});
                if entityType ~= aod.common.EntityTypes.DEVICE
                    error('remove:InvalidEntityType', ...
                        'Only Device can be removed from Channel');
                end
                ID = varargin{2};
            elseif nargin == 2
                ID = varargin{1};
            end

            if isnumeric(ID)
                mustBeInteger(ID); mustBeInRange(ID, 1, numel(obj.Devices));
                removeParent(obj.Devices(ID));
                obj.Devices(ID) = [];
            elseif istext(ID) && strcmpi(ID, 'all')
                removeParent(obj.Devices);
                obj.Devices = aod.core.Device.empty();
            else
                error('remove:InvalidID',...
                    'ID must be integer indices or "all"');
            end
        end
    end
end