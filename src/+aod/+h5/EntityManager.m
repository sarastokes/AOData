classdef EntityManager < handle 
% ENTITYMANAGER
%
% Description:
%   Indexes all entities within an HDF5 file by their path name, UUID and
%   entity type.
%
% Constructor:
%   obj = EntityManager(hdfName)
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
            if ~obj.hasUUID(uuid)
                error("EntityManager:UuidNotFound",...
                    "The UUID %s is not present", uuid);
            end
            hdfPath = char(obj.Table{obj.Table.UUID == uuid, 'Path'});
        end

        function tf = hasUUID(obj, uuid)
            tf = ismember(uuid, obj.Table.UUID);
        end
    end

    methods (Access = private)
        function processGroups(obj, info)
            [idx, UUID] = findAttribute(info, 'UUID');
            if ~isempty(idx)
                [~, className] = findAttribute(info, 'Class');
                obj.pathMap(UUID) = info.Name;
                if isempty(className)
                    className = 'Unknown';
                end
                obj.classMap(UUID) = className;
                [~, entityType] = findAttribute(info, 'EntityType');
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
end