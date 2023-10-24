classdef Link < aod.schema.primitives.Primitive
% LINK
%
% Superclasses:
%   aod.specification.types.Primitive
%
% Constructor:
%   obj = aod.specification.types.Link(name, varargin)
%   obj = aod.specification.types.Link(name,...
%       'EntityType', entityType)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        EntityType        aod.schema.validators.EntityType
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.LINK
        OPTIONS = ["EntityType", "Description"];
        VALIDATORS = ["Size", "EntityType"];
    end

    methods
        function obj = Link(name, varargin)
            obj = obj@aod.schema.primitives.Primitive(name);
            obj.EntityType = aod.schema.validators.EntityType(obj, []);

            if nargin > 2
                obj.setEntityType(entityType);
            end

            obj.Size.setValue("(1,1)");
            % TODO: Set default value of empty class?

            % Restrict parent types
            obj.ALLOWABLE_PARENT_TYPES = "Dataset";
        end
    end

    methods
        function setEntityType(obj, value)
            obj.EntityType.setValue(value);
            if isempty(value)
                obj.setFormat([]);
            else
                obj.setFormat([...
                    string(obj.EntityType.Value.getCoreClassName()),...
                    string(obj.EntityType.Value.getPersistentClassName())]);
            end
        end
    end
end