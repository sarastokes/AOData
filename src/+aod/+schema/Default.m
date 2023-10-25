classdef Default < aod.specification.Specification
% Specifies a default value for a property
%
% Superclasses:
%   aod.specification.Specification
%
% Constructor:
%   aod.schema.Default(parent, input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value           = []
    end

    methods
        function obj = Default(parent, input)
            arguments
                parent      {mustBeScalarOrEmpty} = []
                input                             = []
            end

            obj = obj@aod.specification.Specification(parent);
            obj.setValue(input);
        end
    end

    methods
        function setValue(obj, input)
            if isempty(input)
                obj.Value = [];
            elseif isa(input, 'meta.property')
                if input.HasDefault
                    obj.Value = input.DefaultValue;
                end
            elseif istext(input) && ismember(input, ["", "[]"])
                obj.Value = [];
            else
                obj.Value = input;
            end
        end

        function out = text(obj)
            out = value2string(obj.Value);
            out = convertCharsToStrings(out);
        end
    end

    % MATLAB built-in methods
    methods
        function tf = isempty(obj)
            if isstring(obj.Value) && all(isequal(obj.Value, ""))
                tf = true;
            else
                tf = isempty(obj.Value);
            end
        end

        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.Default');
                tf = false;
            else
                tf = isequal(obj.Value, other.Value);
            end
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