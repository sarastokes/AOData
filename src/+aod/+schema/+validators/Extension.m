classdef Extension < aod.schema.Validator
% Extension
%
% Superclasses:
%   aod.schema.Validator
%
% Constructor:
%   obj = aod.schema.validators.Extension(parent, value)
%
% Examples:
%   % Extension type must be .txt
%   obj = aod.schema.validators.Extension([], ".txt");
%   % Extension type can be .txt or .csv
%   obj = aod.schema.validators.Extension([], [".txt", ".csv"]);
%   % Extension type is unrestricted
%   obj = aod.schema.validators.Extension([], []);

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value       string      = ""
    end

    methods
        function obj = Extension(parent, value)
            arguments
                parent          {mustBeScalarOrEmpty}
                value   string                        = []
            end

            obj = obj@aod.schema.Validator(parent);
            if nargin > 1
                obj.setValue(value);
            end
        end

        function setValue(obj, value)
            arguments
                obj
                value       string
            end

            if numel(value) == 1 && aod.util.isempty(value)
                obj.Value = "";
                return
            elseif numel(value) > 1
                if any(arrayfun(@aod.util.isempty, value))
                    error('setExtension:SomeValuesEmpty',...
                        "%u of %u values were empty, empty values must be singular",...
                        nnz(value == ""), numel(value));
                elseif ~isvector(value)
                    error('setExtension:InvalidSize',...
                        'Extensions must be a vector, size was %s',...
                        value2string(size(value)));
                end
            end

            if iscolumn(value)
                value = value';
            end

            if any(arrayfun(@(x) ~startsWith(x, '.'), value))
                error('setExtension:InvalidExtensionFormat',...
                    'Each extension must start with a period');
            end

            obj.Value = value;
        end

        function [tf, ME] = validate(obj, input)
            tf = true; ME = [];
            if aod.util.isempty(input) || ~obj.isSpecified()
                return
            end

            input = convertCharsToStrings(input);
            if ~endsWith(input, obj.Value)
                tf = false;
                [~, ~, actualExt] = fileparts(input);
                if aod.util.isempty(actualExt)
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
            if ~obj.isSpecified()
                out = "[]";
            else
                out = strjoin(obj.Value, ", ");
            end
        end

        function tf = isSpecified(obj)
            tf = ~aod.util.isempty(obj.Value);
        end
    end

    % MATLAB builtin functions
    methods
        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.validators.Extension')
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