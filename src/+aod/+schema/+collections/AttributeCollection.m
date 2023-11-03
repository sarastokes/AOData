classdef AttributeCollection < aod.schema.SchemaColleRecordCollectionction
% ATTRIBUTECOLLECTION  A collection of attribute schemas
%
% Superclasses:
%   aod.schema.RecordCollection
%
% Constructor:
%   obj = aod.schema.collections.AttributeCollection(className)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        schemaType = "Attribute"
        ALLOWABLE_PRIMITIVE_TYPES = [...
            aod.schema.primitives.PrimitiveTypes.TEXT,...
            aod.schema.primitives.PrimitiveTypes.BOOLEAN,...
            aod.schema.primitives.PrimitiveTypes.NUMBER,...
            aod.schema.primitives.PrimitiveTypes.INTEGER,...
            aod.schema.primitives.PrimitiveTypes.DATETIME,...
            aod.schema.primitives.PrimitiveTypes.LIST,...
            aod.schema.primitives.PrimitiveTypes.UNKNOWN];
    end

    methods
        function obj = AttributeCollection(parent)
            arguments
                parent
            end
            obj = obj@aod.schema.RecordCollection(parent);
        end
    end

    methods
        function add(obj, attrName, primitiveType, varargin)
            % ADD
            %
            % Syntax:
            %   add(obj, attrNameName, primitiveType, varargin)
            % --------------------------------------------------------------

            if isa(attrName, 'aod.schema.Record')
                record = attrName;
            else
                if nargin < 3
                    error('add:InsufficientInput',...
                        'Must at least specify attribute name and type');
                end
                record = aod.schema.Record(obj, attrName, primitiveType, varargin{:});
            end

            if ismember(record.Name, aod.infra.getSystemAttributes())
                error('add:InvalidAttributeName',...
                    'Attribute name %s is reserved by AOData. See aod.h5.getSystemAttributes', record.Name);
            end

            add@aod.schema.RecordCollection(obj, record);
        end

        function ip = getParser(obj)
            ip = aod.util.InputParser();
            for i = 1:obj.Count
                addParameter(ip, obj.Records(i).Name,...
                    obj.Records(i).Primitive.Default, ...
                    @(x) obj.Records(i).Primitive.validate(x));
            end
        end
    end

    methods (Access = ?aod.schema.Schema)
        function setClassName(obj, className)
            % Set the class name
            %
            % Description:
            %   Used by core interface to support the use of a static method
            %   for determining inherited and specified attributes
            %
            % Syntax:
            %   setClassName(obj, className)
            % -------------------------------------------------------------
            obj.className = className;
        end
    end

    methods (Static)
        function obj = populate(className)
            % Create SchemaCollection independent of parent entity
            obj = aod.schema.util.StandaloneSchema(className);
            obj = obj.Attributes;
        end
    end
end