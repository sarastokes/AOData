classdef Link < aod.schema.Primitive
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
        OPTIONS = ["EntityType", "Class", "Description"];
        VALIDATORS = ["Size", "EntityType"];
    end

    methods
        function obj = Link(name, parent, varargin)
            obj = obj@aod.schema.Primitive(name, parent);

            obj.EntityType = aod.schema.validators.EntityType(obj, []);

            obj.Size.setValue("(1,1)");
            % TODO: Set default value of empty class?

            % Restrict parent types
            obj.ALLOWABLE_PARENT_TYPES = "Dataset";

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function setEntityType(obj, value)
            obj.EntityType.setValue(value);
            if isempty(value)
                obj.setClass([]);
            else
                obj.setClass([...
                    string(obj.EntityType.Value.getCoreClassName()),...
                    string(obj.EntityType.Value.getPersistentClassName())]);
            end
        end
    end

    methods
        function [tf, ME, excObj] = checkIntegrity(obj, throwError)
            arguments
                obj
                throwError          logical = false
            end

            if obj.isInitializing
                tf = true; ME = [];
                return
            end

            [tf, ME, excObj] = checkIntegrity@aod.schema.Primitive(obj);
            if throwError && excObj.hasErrors()
                throw(ME);
            end
        end
    end
end