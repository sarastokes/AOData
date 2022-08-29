classdef EntityManager < handle 

    properties
        hdfName
        pathMap
        classMap
        entityMap
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
        end

        function collect(obj)
            obj.clearMaps();

            info = h5info(obj.hdfName);
            obj.processGroups(info.Groups);
        end

        function T = table(obj)
            T = table(string(obj.entityMap.keys'),... 
                string(obj.entityMap.values'),...
                string(obj.classMap.values'),...
                string(obj.pathMap.values'),...
                'VariableNames', {'UUID', 'Entity', 'Class', 'Path'});
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