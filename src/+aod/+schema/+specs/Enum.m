classdef Enum < aod.specification.Validator
% ENUM
%
% Superclasses:
%   aod.specification.Specification
%
% Constructor:
%   obj = aod.schema.specs.Enum(parent, value)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value   {mustBeText, mustBeVector} = ""
    end

    methods
        function obj = Enum(parent, value)
            obj = obj@aod.specification.Validator(parent);
            obj.setValue(value);
        end
    end

    methods

        function setValue(obj, input)
            arguments
                obj
                input  (1,:)    string {mustBeText, mustBeVector} = []
            end

            if isvector(input) && ~isrow(input)
                input = input';
            end
            obj.Value = input;
        end

        function [tf, ME] = validate(obj, input)
            if isempty(obj)
                tf = true; ME = [];
                return
            end

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

        function out = text(obj)
            if obj.isempty()
                out = "[]";
            else
                out = obj.Value;
            end
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isempty(obj)
            tf = aod.util.isempty(obj.Value);
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