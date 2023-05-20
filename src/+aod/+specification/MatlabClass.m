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
        function obj = MatlabClass(classes)
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

        function tf = validate(obj, value)
            if isempty(obj)
                tf = true;
                return
            end
            tf = isSubclass(value, obj.Value);
        end

        function out = text(obj)
            if numel(obj.Value) > 1
                out = array2commalist(obj.Value);
            else
                out = obj.Value;
            end        
        end
    end

    methods (Static, Access = private)
        function classes = parse(input)

            if isa(input, 'meta.property')
                if ~isempty(input.Validation.Class)
                    input = input.Validation.Class.Name;
                end
            end

            if aod.util.isempty(input)
                classes = "";
                return
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
                    error('MatlabClass:UnidentifiedClass',...
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
    end
end