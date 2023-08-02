classdef Enum < aod.specification.Specification
% ENUM
%
% Superclasses:
%   aod.specification.Specification
%
% Constructor:
%   obj = aod.schema.specs.Enum(parent, value)

% By Sara Patterson, 2023 (AOData)
% ---------------------------------------------------------------------

    properties
        Value   {mustBeText} = ""
    end

    methods
        function obj = Enum(parent, value)
            obj = obj@aod.specification.Specification(parent);
            obj.setValue(value);
        end
    end

    methods

        function setValue(obj, input)
            arguments
                obj
                input  (1,:)    string {mustBeText, mustBeVector}
            end

            obj.Value = input;
        end

        function [tf, ME] = validate(obj, input)
            if ~istext(input)
                tf = false;
                ME = MException('validate:InvalidClass',...
                    'Input must be string or char, not %s', class(input));
                return
            end

            tf = ismember(input, obj.Value);
            if ~tf
                ME = MException('validate:InvalidEnum',...
                    'Input must be one of %s', strjoin(obj.Value, ', '));
            else
                ME = [];
            end
        end
    end

    methods
        function tf = isempty(obj)
            tf = aod.util.isempty(obj.Value);
        end
    end

end