classdef (Abstract) Container < aod.schema.primitives.Primitive
% CONTAINER (Abstract)
%
% Superclasses:
%   aod.schema.primitives.Primitive

% By Sara Patterson, 2023 (AOData)
% ----------------------------------------------------------------------

    properties (SetAccess = protected)
        Fields
    end

    properties (Hidden, SetAccess = protected)
        ALLOWABLE_CHILD_TYPES = [...
            aod.schema.primitives.PrimitiveTypes.TEXT,...
            aod.schema.primitives.PrimitiveTypes.NUMBER,...
            aod.schema.primitives.PrimitiveTypes.INTEGER,...
            aod.schema.primitives.PrimitiveTypes.DURATION,...
            aod.schema.primitives.PrimitiveTypes.DATE,...
            aod.schema.primitives.PrimitiveTypes.BOOLEAN];
    end

    methods
        function obj = Container(name, parent, varargin)
            if nargin < 3
                parent = [];
            end
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            obj.addField(varargin{:});
        end
    end

    methods
        function component = getField(obj, fieldName)
            idx = find(strcmp(fieldName, vertcat(obj.Fields.Name)));

            if isempty(idx)
                error('getField:InvalidField',...
                    'Field %s not found in %s', fieldName, obj.Name);
            end
            component = obj.Components(idx);
        end

        function addField(obj, field)
            arguments
                obj
                field           aod.schema.primitives.Primitive
            end

            if ~isscalar(field)
                arrayfun(@(x) addField(obj, x), field);
                return;
            end

            if ~ismember(field.PRIMITIVE_TYPE, obj.ALLOWABLE_CHILD_TYPES)
                error('addField:InvalidPrimitive',...
                    'Field %s cannot be added to %s because it has a primitive type (%s) that is not supported for containers',...
                    field.Name, obj.Name, string(field.PRIMITIVE_TYPE));
            end

            obj.Fields = [obj.Fields; field];
        end
    end

    methods
        function assign(obj, fieldName, varargin)
            f = obj.getField(fieldName);
            f.assign(varargin{:});
        end
    end
end