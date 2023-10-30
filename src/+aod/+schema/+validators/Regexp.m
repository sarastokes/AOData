classdef Regexp < aod.schema.Validator

    properties
        Value         string = ""
    end

    methods
        function obj = Regexp(parent, value)
            obj = obj@aod.schema.Validator(parent);

            if ~isempty(value)
                obj.setValue(value);
            end
        end
    end

    methods
        function setValue(obj, input)
            arguments
                obj
                input         string
            end

            % TODO: Pick column or row
            if aod.util.isempty(input) || input == "[]"
                obj.Value = [];
            else
                if ~isvector(input)
                    error('setValue:InvalidDimensions',...
                        'Input must be a vector but had size %s', value2string(size(input)));
                end
                obj.Value = input;
            end
        end

        function [tf, ME] = validate(obj, input)

            tf = true; ME = [];
            if ~obj.isSpecified
                return
            else
                tf = ~isempty(regexp(input, obj.Value, 'once'));
                if ~tf
                    ME = MException('validate:RegexpFailed',...
                        'Regular expression validation failed.');
                end
            end
        end

        function out = text(obj)
            out = value2string(obj.Value);
        end
    end

    % MATLAB builtin functions
    methods
        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.validators.Regexp')
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