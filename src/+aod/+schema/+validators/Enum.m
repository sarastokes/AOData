classdef Enum < aod.schema.Validator
% ENUM
%
% Description:
%   A vector of allowable values for Integer, Number and Text
%
% Superclasses:
%   aod.schema.Validator
%
% Constructor:
%   obj = aod.schema.validators.Enum(parent, value)
%
% Example:
%   obj = aod.schema.validators.Enum([], ["low", "medium", "high"])
%   obj = aod.schema.validators.Enum([], [1, 2, 3])

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value
    end

    methods
        function obj = Enum(parent, value)
            obj = obj@aod.schema.Validator(parent);
            obj.setValue(value);
        end
    end

    methods
        function setValue(obj, input)

            if all(aod.util.isempty(input))
                obj.Value = [];
                return
            end

            input = convertCharsToStrings(input);
            if ~isvector(input)
                error('setValue:InvalidEnumSize',...
                    'Input should be a vector, not a %s array', value2string(size(input)));
            elseif ~isnumeric(input) && ~isstring(input)
                error('setValue:InvalidEnumType',...
                    'Input should be a numeric or text array, not a %s', class(input));
            end

            if isvector(input) && ~isrow(input)
                input = input';
            end

            obj.Value = input;
        end

        function [tf, ME] = validate(obj, input)
            if ~obj.isSpecified()
                tf = true; ME = [];
                return
            end

            %if ~istext(input)
            %    tf = false;
            %    ME = MException('Enum:validate:InvalidClass',...
            %        'Input must be string or char, not %s', class(input));
            %    return
            %end

            tf = ismember(input, obj.Value);
            if ~tf
                ME = MException('Enum:validate:InvalidEnum',...
                    'Input must be one of %s', value2string(obj.Value));
            else
                ME = [];
            end
        end

        function out = text(obj)
            out = value2string(obj.Value);
            out = convertCharsToStrings(out);
        end

        function tf = isSpecified(obj)
            tf = ~aod.util.isempty(obj.Value);
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.validators.Enum')
                tf = false;
                return
            end

            if numel(obj.Value) ~= numel(other.Value)
                tf = false;
                return
            end

            tf = isempty(setdiff(obj.Value, other.Value));
        end
    end
end