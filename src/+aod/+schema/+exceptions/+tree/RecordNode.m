classdef RecordNode < aod.schema.exceptions.tree.ExceptionNode

    properties (SetAccess = private)
        Name                    string
        primtiveType            aod.schema.PrimitiveTypes
        recordType              aod.schema.RecordTypes
    end

    methods
        function obj = RecordNode(record, varargin)
            obj = obj@aod.schema.exceptions.tree.ExceptionNode(varargin{:});

            obj.Name = record.Name;
            obj.primitiveType = record.primitiveType;
            if ~isempty(record.Parent)
                obj.recordType = record.Parent.recordType;
            end
        end
    end

    methods
        function out = text(obj, indentLevel)
            arguments
                obj
                indentLevel         = obj.SCHEMA_LEVEL
            end

            indent = obj.getIndent(indentLevel);
            if obj.totalNumErrors == 0
                out = "";
                return
            end

            out = sprintf("%s%s (%s, %s)\n", indent, obj.Name,...
                string(obj.recordType), string(obj.primitiveType));
            for i = 1:obj.numErrors
                out = out + sprintf("%s! %s\n", indent+4, obj.Causes(i).Message);
            end
            if obj.totalNumErrors > obj.numErrors
                for i = 1:numel(obj.Children)
                    out = out + obj.Children(i).text(indentLevel + 2);
                end
            end
        end
    end
end