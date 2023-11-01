classdef SchemaContainer < handle

    properties (SetAccess = private)
        Schemas
        classNames
    end

    methods
        function obj = SchemaContainer()
            
        end

        function add(obj, schema)
            arguments
                obj
                schema          aod.schema.Schema
            end

            if ismember(schema.className, obj.classNames)
                % TODO: Check for equality
                return
            end

            obj.Schemas = cat(1, obj.Schemas, schema);
            obj.classNames = cat(1, obj.classNames, className);
        end 
    end
end