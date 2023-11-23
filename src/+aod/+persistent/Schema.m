classdef Schema < aod.schema.Schema
% SCHEMA
%
% Description:
%   Represents the schema of a persisted Entity within an HDF5 file
%
% Superclasses:
%   aod.schema.Schema
%
% Constructor:
%   obj = aod.persistent.Schema(parent)

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (Access = private)
        isPopulated       (1,1)       logical
    end

    methods
        function obj = Schema(parent)
            if isempty(parent)
               parent = [];
            end
            obj = obj@aod.schema.Schema(parent);

            obj.isPopulated = false;

            obj.DatasetCollection = aod.schema.collections.DatasetCollection(obj.Parent);
            obj.AttributeCollection = aod.schema.collections.AttributeCollection(obj.Parent);
            obj.FileCollection = aod.schema.collections.FileCollection(obj.Parent);

            obj.entityType = obj.Parent.entityType;
            obj.classUUID = obj.Parent.classUUID;
        end
    end

    methods (Access = protected)
        function value = getDatasetCollection(obj)
            if ~obj.isPopulated
                obj.collectSchemas();
            end
            value = obj.DatasetCollection;
        end

        function value = getAttributeCollection(obj)
            if ~obj.isPopulated
                obj.collectSchemas();
            end
            value = obj.AttributeCollection;
        end

        function value = getFileCollection(obj)
            if ~obj.isPopulated
                obj.collectSchemas();
            end
            value = obj.FileCollection;
        end

        function setClassName(obj, className)
            if ~isSubclass(className, ["aod.core.Entity", "aod.persistent.Entity"])
                error('setClassName:InvalidClass',...
                    'Class %s is not a subclass of aod.core.Entity', className);
            end

            obj.className = className;
        end
    end

    methods (Access = private)
        function collectSchemas(obj)
            out = h5read(obj.Parent.hdfName,...
                h5tools.util.buildPath(obj.Parent.hdfPath, 'Schema'));
            S = jsondecode(out);

            obj.DatasetCollection = aod.h5.readSchemaCollection(S.Datasets, obj.DatasetCollection);
            obj.AttributeCollection = aod.h5.readSchemaCollection(S.Attributes, obj.AttributeCollection);
            obj.FileCollection = aod.h5.readSchemaCollection(S.Files, obj.FileCollection);

            obj.isPopulated = true;
        end
    end
end