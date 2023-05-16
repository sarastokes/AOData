classdef EntityManager < handle 
% ENTITYMANAGER
%
% Description:
%   Indexes all entities within an HDF5 file by their path name, UUID and
%   entity type.
%
% Constructor:
%   obj = EntityManager(hdfName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    

    properties
        hdfName            
        pathMap
        classMap
        entityMap
        Table
    end

    methods
        function obj = EntityManager(hdfName)
            obj.hdfName = hdfName;
            obj.collect();
        end

        function clearMaps(obj)
            obj.entityMap = containers.Map();
            obj.classMap = containers.Map();
            obj.pathMap = containers.Map();
            obj.Table = [];
        end

        function collect(obj)
            obj.clearMaps();

            info = h5info(obj.hdfName);
            obj.processGroups(info.Groups);

            obj.Table = table(obj);
        end

        function T = table(obj)
            T = table(string(obj.entityMap.keys'),... 
                string(obj.entityMap.values'),...
                string(obj.classMap.values'),...
                string(obj.pathMap.values'),...
                'VariableNames', {'UUID', 'Entity', 'Class', 'Path'});
        end

        function hdfPath = uuid2path(obj, uuid)
            uuid = aod.util.validateUUID(uuid);
            if ~obj.hasUUID(uuid)
                error("EntityManager:UuidNotFound",...
                    "The UUID %s is not present", uuid);
            end
            hdfPath = char(obj.Table{obj.Table.UUID == uuid, 'Path'});
        end

        function uuid = path2uuid(obj, path)
            uuid = obj.Table{obj.Table.Path == path, 'UUID'};
        end

        function tf = hasUUID(obj, uuid)
            uuid = aod.util.validateUUID(uuid);
            tf = ismember(uuid, obj.Table.UUID);
        end

        function paths = getEntityChildren(obj, entity)
            if isa(entity, 'aod.persistent.Entity')
                hdfPath = entity.hdfPath;
            elseif istext(entity)
                hdfPath = convertCharsToStrings(entity);
            end 

            paths = obj.Table.Path(...
                startsWith(obj.Table.Path, hdfPath) & ...
                strlength(obj.Table.Path) > strlength(hdfPath));
        end
    end

    methods (Access = private)
        function processGroups(obj, info)
            [idx, UUID] = obj.findAttribute(info, 'UUID');
            if ~isempty(idx)
                [~, className] = obj.findAttribute(info, 'Class');
                obj.pathMap(UUID) = info.Name;
                if isempty(className)
                    className = 'Unknown';
                end
                obj.classMap(UUID) = className;
                [~, entityType] = obj.findAttribute(info, 'EntityType');
                obj.entityMap(UUID) = entityType;
            end

            % Recursively call for child groups
            if ~isempty(info.Groups)
                for i = 1:numel(info.Groups)
                    obj.processGroups(info.Groups(i));
                end
            end
        end
    end

    methods (Static)
        function [idx, attributeValue] = findAttribute(info, attributeName)
            % FINDATTRIBUTE
            %
            % Syntax:
            %   [idx, attributeValue] = findAttribute(info, attributeName)
            %
            % TODO: Out of date - use faster h5tools-matlab functions
            % ---------------------------------------------------------------------
            arguments
                info                struct 
                attributeName       char 
            end

            if isempty(info.Attributes)
                idx = []; attributeValue = [];
                return
            end

            idx = arrayfun(@(x) strcmp(x.Name, attributeName), info.Attributes);
            idx = find(idx);

            if ~isempty(idx)
                attributeValue = info.Attributes(idx).Value;
                if iscell(attributeValue)
                    attributeValue = cell2mat(attributeValue);
                end
            else
                attributeValue = [];
            end
        end
    end
end