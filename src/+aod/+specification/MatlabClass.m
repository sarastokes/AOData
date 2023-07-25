classdef MatlabClass < aod.specification.Validator
%
% Superclass:
%   aod.specification.Validator
%
% Constructor:
%   obj = aod.specification.MatlabClass(input)
%
% Inputs:
%   input           char, string, cellstr or meta.property
%       MATLAB class or classes

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value   (1,:)       string = ""
    end

    methods
        function obj = MatlabClass(classes, parent)
            if nargin < 2
                parent = [];
            end
            obj = obj@aod.specification.Validator(parent);
            
            if nargin > 0
                obj.Value = obj.parse(classes);
            end
        end
    end

    % aod.specification.Specification methods
    methods 
        function setValue(obj, input)
            obj.Value = obj.parse(input);
        end

        function [tf, ME] = validate(obj, value)
            if isempty(obj)
                tf = true; ME = [];
                return
            end
            tf = isSubclass(value, obj.Value);
            if tf
                ME = [];
            else
                ME = MException("MatlabClass:validate",...
                    "Expected class: %s. Actual class: %s",...
                    obj.text(), class(value));
            end
        end

        function out = text(obj)
            if isempty(obj)
                out = "[]";
            elseif numel(obj.Value) > 1
                out = array2commalist(obj.Value);
            else
                out = obj.Value;
            end        
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
                error('MatlabClass:InvalidInput',...
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
                    error('MatlabClass:InvalidClass',...
                        'Class %s not recognized', input(i));
                end
            end
        end
    end

    % MATLAB built-in methods
    methods 
        function tf = isempty(obj)
            tf = (obj.Value == "");
        end

        function tf = isequal(obj, other)
            if ~isa(other, 'aod.specification.MatlabClass')
                tf = false;
                return 
            end
            
            if numel(obj.Value) ~= numel(other.Value)
                tf = false; 
                return 
            end

            for i = 1:numel(obj.Value)
                if ~ismember(obj.Value(i), other.Value)
                    tf = false;
                    return 
                end
            end
            tf = true;
        end

        function out = jsonencode(obj)
            if isempty(obj)
                out = jsonencode([]);
            else
                out = jsonencode(obj.Value);
            end
        end
    end
end