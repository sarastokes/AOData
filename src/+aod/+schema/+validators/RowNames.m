classdef RowNames < aod.schema.Validator

    properties (SetAccess = private)
        Value
    end
    
    methods
        function obj = RowNames(parent, value)
            obj = obj@aod.schema.Validator(parent);
            
            if ~aod.util.isempty(value)
                obj.setValue(value);
            end
        end
    end

    methods
        function setValue(obj, value)
            arguments
                obj
                value       string
            end

            if aod.util.isempty(value)
                obj.Value = [];
                return
            end

            mustBeVector(value);
            if iscolumn(value)
                value = value';
            end
            obj.Value = value;
        end

        function [tf, ME] = validate(obj, input)
            ME = [];
            if ~obj.isSpecified() || aod.util.isempty(input)
                tf = true;
                return
            end

            if isstruct(input) || isa(input, 'containers.Map')
                if isstruct(input)
                    f = fieldnames(input);
                else
                    f = input.keys();
                end

                f = string(f);
                extraNames = setdiff(f, obj.Value);
                missingNames = setdiff(obj.Value, f);
                tf = ~isempty(extraNames) || ~isempty(missingNames);

                str = "";
                if ~tf && ~isempty(missingNames)
                    str = str + sprintf("Input was missing fields %s",...
                        strjoin(missingNames, ', '));
                end
                if ~tf && ~isempty(extraNames)
                    str = str + sprintf("Input had extra fields %s",...
                        strjoin(extraNames, ', '));
                end
                ME = MException("RowNames:validate:InvalidFields", str);
            elseif istable(input)
                tf = height(input) == length(obj.Value);
                if ~tf
                    ME = MException('RowNames:validate:InvalidHeight',...
                        'The height (%u) did not match the number of row names (%u)',...
                        height(input), length(obj.Value));
                end
                % TODO: Rownames content check
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

    % MATLAB builtin functions
    methods
        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.decorators.Units')
                tf = false;
                return
            end

            tf = isequal(obj.Value, other.Value);
        end
    end
end