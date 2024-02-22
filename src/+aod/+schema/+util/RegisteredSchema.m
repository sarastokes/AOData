classdef RegisteredSchema < aod.persistent.Schema
% REGISTEREDSCHEMA
%
% Superclasses:
%   aod.persistent.Schema
% TODO Swap to parent, maybe real-time representation (no registry param)

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = RegisteredSchema(className, registry)
            arguments
                className   (1,1)  string
                registry    aod.schema.Registry = aod.schema.Registry()
            end

            obj = obj@aod.persistent.Schema([]);
            obj.setClassName(className);

            S = registry.getSchema(obj.className);
            obj.entityType = aod.common.EntityTypes.get(S.EntityType);
            obj.classUUID = S.UUID;
            obj.collectSchemas(S);
        end
    end

    methods (Access = private)
        function collectSchemas(obj, S)

            obj.DatasetCollection = aod.h5.readSchemaCollection(...
                S.Datasets, obj.DatasetCollection);
            obj.DatasetCollection.setClassName(obj.className);

            obj.AttributeCollection = aod.h5.readSchemaCollection(...
                S.Attributes, obj.AttributeCollection);
            obj.AttributeCollection.setClassName(obj.className);

            obj.FileCollection = aod.h5.readSchemaCollection(...
                S.Files, obj.FileCollection);
            obj.FileCollection.setClassName(obj.className);

            obj.isPopulated = true;
        end

        function tf = checkUUID(uuid1, uuid2)
            tf = isequal(uuid1, uuid2);
        end
    end
end