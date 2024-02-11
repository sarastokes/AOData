classdef EntityNode < aod.schema.exceptions.tree.ExceptionNode

    properties (SetAccess = private)
        Name                string
        entityType          aod.common.EntityTypes
        entityClass         string
        hdfPath             string
    end

    properties (Dependent)
        Datasets
        Attributes
        Files
    end

    methods
        function obj = EntityNode(entity, varargin)
            obj = obj@aod.schema.exceptions.tree.ExceptionNode(varargin{:});

            obj.Name = entity.groupName;
            obj.entityType = entity.Type;
            if isSubclass(entity, 'aod.persistent.Entity')
                obj.entityClass = entity.matlabClass;
            else
                obj.entityClass = class(entity);
            end
            obj.hdfPath = entity.hdfPath;
        end
    end

    methods
        function out = text(obj, indentLevel)
            arguments
                obj
                indentLevel     double      {mustBeInteger} = obj.SCHEMA_LEVEL
            end

            indent = obj.getIndent(indentLevel);

            % EntityName (hdfPath)
            %    ! Entity exceptions (1, 2, 3...)
            %  RecordName (recordType, primitiveType)
            %     ! Record exceptions (Validator + msg,...)
            %    ItemName (primitiveType)
            %        ! Item exceptions (Validator + msg,...)
            if obj.totalExceptions == 0
                out = "";
                return
            end

            out = sprintf("%s (%s)\n", indent, obj.Name, obj.hdfPath);
            if ~isempty(obj.causes)
                for i = 1:numel(obj.Causes)
                    out = out + sprintf("! %s%s\n", indent + "  ", obj.Causes(i).Message);
                end
            end
            for i = 1:numel(obj.Children)
                out = out + obj.Children(i).text(indentLevel + 2);
            end
            out = out + "\n";
        end
    end

    % Dependent set/get methods
    methods
        function value = get.Datasets(obj)
            if obj.numChildren == 0
                value = [];
            else
                value = obj.Children(obj.Children.recordType == aod.schema.RecordTypes.DATASET);
            end
        end

        function value = get.Attributes(obj)
            if obj.numChildren == 0
                value = [];
            else
                value = obj.Children(obj.Children.recordType == aod.schema.RecordTypes.ATTRIBUTE);
            end
        end

        function value = get.Files(obj)
            if obj.numChildren == 0
                value = [];
            else
                value = obj.Children(obj.Children.recordType == aod.schema.RecordTypes.FILE);
            end
        end
    end
end