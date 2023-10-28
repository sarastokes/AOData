classdef AttributeCollection < aod.schema.SchemaCollection
% ATTRIBUTECOLLECTION  A collection of attribute schemas
%
% Superclasses:
%   aod.schema.SchemaCollection
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
            aod.schema.primitives.PrimitiveTypes.INTEGER];
    end

    methods
        function obj = AttributeCollection(className, parent)
            arguments
                className       string    = []
                parent                    = []
            end
            obj = obj@aod.schema.SchemaCollection(className, parent);
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
                entry = attrName;
            else
                if nargin < 3
                    error('add:InsufficientInput',...
                        'Must at least specify attribute name and type');
                end
                entry = aod.schema.Record(obj, attrName, primitiveType, varargin{:});
            end

            add@aod.schema.SchemaCollection(obj, entry);
        end

        function ip = getParser(obj)
            % Amazingly this works
            ip = aod.util.InputParser();
            for i = 1:obj.Count
                addParameter(ip, obj.Records(i).Name,...
                    obj.Records(i).Primitive.Default, ...
                    @(x) obj.Records(i).Primitive.validate(x));
            end
        end
    end

    methods (Access = ?aod.schema.EntitySchema)
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
            % TODO: Modify entity framework
        end
    end
end