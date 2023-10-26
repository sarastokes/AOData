classdef Enum < aod.schema.Validator
% ENUM
%
% Superclasses:
%   aod.schema.Validator
%
% Constructor:
%   obj = aod.schema.validators.Enum(parent, value)
%
% Example:
%   obj = aod.schema.validators.Enum([], ["low", "medium", "high"])

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value   {mustBeText, mustBeVector} = ""
    end

    methods
        function obj = Enum(parent, value)
            obj = obj@aod.schema.Validator(parent);
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
            if ~obj.isSpecified()
                tf = true; ME = [];
                return
            end

            if ~istext(input)
                tf = false;
                ME = MException('Enum:validate:InvalidClass',...
                    'Input must be string or char, not %s', class(input));
                return
            end

            tf = ismember(input, obj.Value);
            if ~tf
                ME = MException('Enum:validate:InvalidEnum',...
                    'Input must be one of %s', strjoin(obj.Value, ', '));
            else
                ME = [];
            end
        end

        function out = text(obj)
            if ~obj.isSpecified()
                out = "[]";
            else
                out = obj.Value;
            end
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isSpecified(obj)
            tf = ~aod.util.isempty(obj.Value);
        end
    end
end