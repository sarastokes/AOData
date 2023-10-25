classdef EntityType < aod.specification.Validator
% EntityType - Entity type validator
%
% Superclasses:
%   aod.specification.Validator
%
% Constructor:
%   obj = aod.schema.validators.EntityType(value)
%
% See also:
%   aod.common.EntityTypes

% By Sara Patterson, 2023 (AOData)
% ---------------------------------------------------------------------

    properties (SetAccess = private)
        Value           {mustBeScalarOrEmpty}
    end

    properties (Hidden, SetAccess = protected)
        OPTIONS = ["EntityType", "Description"]
    end

    methods
        function obj = EntityType(parent, value)
            obj = obj@aod.specification.Validator(parent);
            obj.setValue(value);
        end
    end

    methods
        function setValue(obj, input)
            if obj.isInputEmpty(input)
                obj.Value = [];
            else
                obj.Value = aod.common.EntityTypes.get(input);
            end
        end

        function [tf, ME] = validate(obj, input)
            ME = [];
            if obj.isempty() || aod.util.isempty(input)
                tf = true;
            elseif ~aod.util.isEntity(input)
                tf = false;
                ME = MException('AOData:EntityType:Invalid', ...
                    'Links must be to AOData entities, class was %s.', class(input));
            else
                tf = isequal(obj.Value, input.entityType);
                if ~tf
                    ME = MException('AOData:EntityType:Invalid', ...
                        'Invalid entity type (%s).', string(input.entityType));
                else
                    ME = [];
                end
            end
        end

        function out = text(obj)
            if obj.isempty()
                out = "[]";
            else
                out = jsonencode(string(obj.Value));
            end
        end

        function out = jsonencode(obj)
            if obj.isempty()
                out = jsonencode([]);
            else
                out = jsonencode(string(obj.Value));
            end
        end
    end

    % Matlab builtin methods
    methods
        function tf = isempty(obj)
            tf = isempty(obj.Value);
        end
    end
end