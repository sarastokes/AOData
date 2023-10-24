classdef ExtensionType < aod.specification.Validator
% EXTENSIONTYPE
%
% Superclasses:
%   aod.specification.Validator
%
% Constructor:
%   obj = aod.schema.validators.ExtensionType(parent, value)
%
% Examples:
%   % Extension type must be .txt
%   obj = aod.schema.validators.ExtensionType([], ".txt");
%   % Extension type can be .txt or .csv
%   obj = aod.schema.validators.ExtensionType([], [".txt", ".csv"]);
%   % Extension type is unrestricted
%   obj = aod.schema.validators.ExtensionType([], []);

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value       string      = ""
    end

    methods
        function obj = ExtensionType(parent, value)
            arguments
                parent          {mustBeScalarOrEmpty} = []
                value   string  {mustBeVector}        = []
            end

            obj = obj@aod.specification.Validator(parent);
            if nargin > 1 && ~aod.util.isempty(value)
                obj.setValue(value);
            end
        end

        function setValue(obj, value)
            if aod.util.isempty(value)
                obj.Value = "";
                return
            end

            if ~isvector(value)
                error('setExtensionType:InvalidSize',...
                    'Extensions must be a vector, size was %u x %u', size(value));
            end
            if iscolumn(value)
                value = value';
            end

            if any(arrayfun(@(x) ~startsWith(x, '.'), value))
                error('setExtensionType:InvalidExtensionFormat',...
                    'Each extension must start with a period');
            end
            obj.extensionType = value;

            obj.Value = value;
        end

        function [tf, ME] = validate(obj, input)
            tf = true; ME = [];
            if aod.util.isempty(input) || isempty(obj)
                return
            end

            input = convertCharsToStrings(input);
            if ~endsWith(input, obj.Value)
                tf = false;
                [~, ~, actualExt] = fileparts(input);
                if isempty(actualExt)
                    ME = MException('validate:NoExtensionFound',...
                        'No extension found in %s', input);
                else
                    ME = MException('validate:InvalidExtension',...
                        'Extension must be %s, was %s',...
                        strjoin(obj.Value, ', '), actualExt);
                end
            end
        end

        function out = text(obj)
            if isempty(obj)
                out = "[]";
            else
                out = strjoin(obj.Value, ", ");
            end
        end
    end

    % MATLAB builtin functions
    methods
        function tf = isempty(obj)
            tf = aod.util.isempty(obj.Value);
        end

        function out = jsonencode(obj)
            if isempty(obj)
                out = "[]";
            else
                out = jsonencode(obj.Value);
            end
        end
    end
end