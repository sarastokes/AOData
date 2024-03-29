classdef Description < aod.schema.Decorator
% DESCRIPTION
%
% Description:
%   A open-ended text field for describing a variable
%
% Superclass:
%   aod.schema.Decorator
%
% Constructor:
%   obj = aod.schema.decorators.Description(input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Description(parent, input)
            arguments
                parent          = []
                input           = []
            end
            obj = obj@aod.schema.Decorator(parent);
            if aod.util.isempty(input) || input == "[]"
                input = "";
            end
            obj.setValue(input);
        end
    end

    % aod.schema.Decorator methods
    methods
        function setValue(obj, input)
            if aod.util.isempty(input) || input == "[]"
                obj.Value = "";
                return
            end

            input = convertCharsToStrings(input);
            mustBeTextScalar(input);

            obj.Value = input;
        end

        function output = text(obj)
            if ~obj.isSpecified()
                output = "[]";
            else
                output = obj.Value;
            end
        end
    end

    % MATLAB builtin functions
    methods
        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.decorators.Description')
                tf = false;
                return
            end

            tf = isequal(obj.Value, other.Value);
        end
    end
end