classdef ParentEntity < handle 
% Shared implementation for entity types that contain child entities
%
% Superclasses:
%   handle
%
% Constructor:
%   N/A
%
% See also:
%   aod.core.Epoch, aod.persistent.Epoch

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

%#ok<*MCNPN>

    methods 
        function tf = has(obj, entityType, varargin)
            % Search Epoch's child entities and return if matches exist
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (see Epoch.get) and return whether matches exist
            %
            % Syntax:
            %   tf = has(obj, entityType, varargin)
            %
            % Inputs:
            %   entityType          char or aod.common.EntityTypes
            % Optional inputs:
            %   One or more cells containing queries
            % -------------------------------------------------------------
            tf = ~isempty(obj.get(entityType, varargin{:}));
        end
        
        function out = get(obj, childType, varargin)
            % Search Epoch's child entities and return matches
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (described below in examples)
            %
            % Inputs:
            %   entityType          char or aod.common.EntityTypes
            % Optional inputs:
            %   One or more cells containing queries
            %
            % Examples:
            % Search for Sources named "OD"
            %   out = obj.get('Source', {'Name', "OD"})
            %
            % Search for Devices of class "aod.builtin.devices.Pinhole"
            %   out = obj.get('Device', {'Class', 'aod.builtin.devices.Pinhole'})
            %
            % Search for Calibrations that are a subclass of
            % "aod.builtin.calibrations.PowerMeasurement"
            %   out = obj.get('Calibration',...
            %       {'Subclass', 'aod.builtin.calibrations.PowerMeasurement'})
            %
            % Search for Epochs that have Attribute "Defocus"
            %   out = obj.get('Epoch', {'Attribute', 'Defocus'})
            %
            % Search for Epochs with Attribute "Defocus" = 0.3
            %   out = obj.get('Epoch', {'Attribute', 'Defocus', 0.3})
            % -------------------------------------------------------------
            
            childType = obj.validateChildType(childType);

            group = obj.(childType.parentContainer());
            if isempty(group) || nargin < 3
                out = group;
                return 
            end

            ID = obj.searchForChildIDs(childType, varargin{:});
            if ~isempty(ID)
                out = group(ID);
            else
                out = [];
            end

            % if nargin > 2 && ~isempty(group)
            %     out = aod.common.EntitySearch.go(group, varargin{:});
            % else
            %     out = group;
            % end
        end

        function add(obj, entity)
            % Add an entity to the Epoch 
            %
            % Description:
            %   Add a new entity to the epoch
            %
            % Syntax:
            %   add(obj, entity)
            %
            % Notes: Only entities contained by Epoch can be added:
            %   EpochDataset, Response, Registration, Stimulus
            % ------------------------------------------------------------- 
            arguments 
                obj
                entity      {mustBeA(entity, 'aod.core.Entity')}
            end

            if ~isscalar(entity)
                arrayfun(@(x) add(obj, x), entity);
                return
            end

            entityType = EntityTypes.get(entity);
            if ~ismember(entityType, obj.entityType.validChildTypes())
                error('remove:InvalidEntityType',...
                    'Entity must be %s', string(obj.entityType.validChildTypes()));
            end
        end

        function remove(obj, childType, varargin)
            % Remove specific entites or clear all entities of a given type
            %
            % Syntax:
            %   remove(obj, entityType, idx)
            %
            % Examples:
            %   % Remove the 2nd calibration
            %   remove(obj, 'Calibration', 2);
            %
            %   % Remove System most recently added (last in obj.Systems)
            %   remove(obj, 'System', 'last')
            %
            %   % Remove all Epochs
            %   remove(obj, 'Epoch', 'all');
            % -------------------------------------------------------------
            
            if isempty(obj.(childType.parentContainer()))
                warning('remove:NoEntitiesToRemove',...
                    "The %s did not have any child %s entities - no changes made", class(obj), string(childType));
                return 
            end

            ID = obj.searchForChildIDs(childType, varargin{:});

            if isempty(ID)
                warning('remove:NoQueryMatches',...
                    'The query returned no matches, no entities removed.');
                return
            end
            ID = sort(ID, 'descend');
            dissociateEntity(obj.(childType.parentContainer())(ID));
        end
    end

    methods (Access = protected)
        function childType = validateChildType(obj, childType)
            
            childType = aod.common.EntityTypes.get(childType);
            if ~ismember(childType, obj(1).entityType.validChildTypes())
                error('remove:InvalidEntityType',...
                    'Entity must be %s',... 
                    strjoin(string(obj.entityType.validChildTypes()), ', ')); 
            end
        end

        function ID = searchForChildIDs(obj, childType, varargin)

            containerName = childType.parentContainer(obj);
            if isempty(obj.(containerName))
                ID = [];
                return
            end

            if istext(varargin{1})
                switch lower(varargin{1})
                    case 'all'
                        ID = 1:numel(obj.(containerName));
                    case 'last'
                        ID = numel(obj.(containerName));
                    otherwise 
                        error('remove:InvalidInput',...
                        "Invalid text input %s. Options: 'all' or 'last'", varargin{1});
                end 
            elseif isnumeric(varargin{1})
                ID = varargin{1};
                mustBeInteger(ID);
                mustBeInRange(ID, 1, numel(obj.(containerName)));
            elseif iscell(varargin{1})
                [~, ID] = aod.common.EntitySearch.go(...
                    obj.(childType.parentContainer()), varargin{:});
            else
                error('remove:InvalidID',...
                    'ID must be "all", "last", query or integer index of entities to remove');
            end
        end
    end
end