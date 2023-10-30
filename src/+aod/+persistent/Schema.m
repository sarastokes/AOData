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
    end

    methods (Access = private)
        function collectSchemas(obj)
            disp('Collecting schema...')
            out = h5read(obj.Parent.hdfName,...
                h5tools.util.buildPath(obj.Parent.hdfPath, 'Schema'));
            S = jsondecode(out);
            fMain = string(fieldnames(S));

            obj.DatasetCollection = aod.h5.readSchemaCollection(S.(fMain).Datasets, obj.DatasetCollection);
            obj.AttributeCollection = aod.h5.readSchemaCollection(S.(fMain).Attributes, obj.AttributeCollection);
            obj.FileCollection = aod.h5.readSchemaCollection(S.(fMain).Files, obj.FileCollection);

            obj.isPopulated = true;
        end
    end
end