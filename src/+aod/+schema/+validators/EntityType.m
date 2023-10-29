classdef EntityType < aod.schema.Validator
% EntityType - Entity type validator
%
% Superclasses:
%   aod.schema.Validator
%
% Constructor:
%   obj = aod.schema.validators.EntityType(value)
%
% See also:
%   aod.common.EntityTypes

% By Sara Patterson, 2023 (AOData)
% ---------------------------------------------------------------------

    properties (SetAccess = private)
        Value
    end

    methods
        function obj = EntityType(parent, value)
            obj = obj@aod.schema.Validator(parent);
            obj.setValue(value);
        end
    end

    methods
        function setValue(obj, input)
            if aod.schema.util.isInputEmpty(input)
                obj.Value = [];
            else
                input = convertCharsToStrings(input);
                obj.Value = arrayfun(@(x) aod.common.EntityTypes.get(x), input);
            end
        end

        function [tf, ME] = validate(obj, input)
            ME = [];
            if ~obj.isSpecified || aod.util.isempty(input)
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
            if ~obj.isSpecified()
                out = "[]";
            else
                out = jsonencode(string(obj.Value));
            end
        end

    end

    % Matlab builtin methods
    methods
        function out = jsonencode(obj, varargin)
            if ~obj.isSpecified()
                out = jsonencode([]);
            else
                out = jsonencode(string(obj.Value));
            end
        end
    end
end