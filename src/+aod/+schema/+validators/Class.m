classdef Class < aod.schema.Validator
% CLASS
%
% Description:
%   Specifies the underlying MATLAB class, or classes
%
% Superclass:
%   aod.schema.Validator
%
% Constructor:
%   obj = aod.specification.Class(input)
%
% Inputs:
%   input           char, string, cellstr or meta.property
%       MATLAB class or classes

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value             string = ""
    end

    methods
        function obj = Class(parent, classes)
            if nargin < 1
                parent = [];
            end
            obj = obj@aod.schema.Validator(parent);

            if nargin > 0
                obj.Value = obj.parse(classes);
            end
        end
    end

    % aod.schema.Specification methods
    methods
        function setValue(obj, input)
            obj.Value = obj.parse(input);
        end

        function [tf, ME] = validate(obj, value)
            if ~obj.isSpecified()
                tf = true; ME = [];
                return
            end

            if ~isSubclass(value, obj.Value)
                tf = false;
                ME = MException("Class:validate",...
                    "Expected class: %s. Actual class: %s",...
                    obj.text(), class(value));
            else
                tf = true;
                ME = [];
            end
        end

        function out = text(obj)
            if ~obj.isSpecified()
                out = "[]";
            elseif numel(obj.Value) > 1
                out = array2commalist(obj.Value);
            else
                out = obj.Value;
            end
        end

        function tf = isSpecified(obj)
            tf = ~aod.util.isempty(obj.Value);
        end
    end

    methods (Static, Access = private)
        function classes = parse(input)

            if aod.util.isempty(input) || istext(input) && all(input == "[]")
                classes = "";
                return
            end

            if isa(input, 'meta.property')
                if ~isempty(input.Validation) && ~isempty(input.Validation.Class)
                    classes = string(input.Validation.Class.Name);
                else
                    classes = "";
                end
                return
            elseif ~istext(input)
                error('Class:parse:InvalidInput',...
                    'Inputs must be char, string or meta.property');
            end

            input = convertCharsToStrings(input);
            if isscalar(input) && contains(input, ',')
                input = strsplit(input, ',');
                input = arrayfun(@strip, input);
            end

            classes = strings(1, numel(input));
            for i = 1:numel(input)
                if exist(input(i), 'builtin') || exist(input(i), 'class')
                    classes(i) = input(i);
                else
                    error('Class:parse:InvalidClass',...
                        'Class %s not recognized', input(i));
                end
            end
        end
    end

    % MATLAB built-in methods
    methods
        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.validators.Class')
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