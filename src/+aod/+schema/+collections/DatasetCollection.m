classdef DatasetCollection < aod.schema.RecordCollection
% DATASETSCHEMA  A collection of attribute schemas
%
% Superclasses:
%   aod.schema.RecordCollection
%
% Constructor:
%   obj = aod.schema.collections.DatasetCollections(className)
%
% Notes:
%   The workflow for DatasetCollection is as follows:
%   - populate() is called to create in the constructor of aod.core.Entity
%   - set() is called in specifyDatasets() to modify default values

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        schemaType        = "Dataset"
        ALLOWABLE_PRIMITIVE_TYPES = aod.schema.primitives.PrimitiveTypes.list()
    end

    methods
        function obj = DatasetCollection(parent)
            obj = obj@aod.schema.RecordCollection(parent);
        end
    end

    methods
        function add(obj, varargin)
            if isa(varargin{1}, 'aod.schema.Record')  % Internal use only
                add@aod.schema.RecordCollection(obj, varargin{:});
            else
                error('add:AdditionNotSupported',...
                    'Ad-hoc property addition is not supported. Datasets must be defined in a property block. Use set() to modify an existing property defined or inherited by the class.');
            end
        end

        function remove(~, ~)
            % TODO: Should I allow this? Seems too error-prone
            error('remove:DatasetRemovalNotSupported',...
                'Datasets defined in a property block cannot be removed from schema');
        end
    end

    methods (Static)
        function obj = populate(className)
            % Populate and create a DatasetManager from a class name
            % Syntax:
            %   obj = aod.schema.EntityDatasets.populate(className)
            %
            % Inputs:
            %   className           string/char, object
            %       Class (must be aod.core.Entity subclass)
            %
            % Examples:
            %   obj = aod.schema.EntityDatasets.populate('aod.core.Epoch')
            % -------------------------------------------------------------

            if ~isSubclass(className, "aod.core.Entity")
                if isa(className, 'meta.class')
                    className = className.Name;
                end
                error('populate:InvalidInput',...
                    'Class %s is not a subclass of aod.core.Entity', className);
            end

            if istext(className)
                mc = meta.class.fromName(className);
            elseif isa(className, 'meta.class')
                mc = className;
            elseif isobject(className)
                mc = metaclass(className);
            else
                error('populate:InvalidInput',...
                    'Input must be class name or meta.class, not %s', ...
                    class(className));
            end


            propList = mc.PropertyList;
            classProps = aod.h5.getPersistedProperties(mc.Name);
            systemProps = aod.infra.getSystemProperties();

            obj = aod.schema.collections.DatasetCollection(mc.Name);
            for i = 1:numel(propList)
                % Skip system properties
                if ismember(propList(i).Name, systemProps)
                    continue
                end

                % Skip properties that will not be persisted
                if ~ismember(propList(i).Name, classProps)
                    continue
                end

                dataObj = aod.schema.Record(obj, propList(i).Name, 'Unknown');
                obj.add(dataObj);
            end
        end
    end
end