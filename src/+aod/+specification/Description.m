classdef Description < aod.specification.Decorator
% DESCRIPTION
%
% Description:
%   A open-ended text field for describing a variable
%
% Superclass:
%   aod.specification.Decorator
%
% Constructor:
%   obj = aod.specification.Decorator(input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    % properties (SetAccess = private)
    %     Value (1,1)         string      = ""
    % end

    methods
        function obj = Description(input, parent)
            if nargin < 2
                parent = [];
            end
            obj = obj@aod.specification.Decorator(parent);
            if nargin < 1 || aod.util.isempty(input) || input == "[]"
                input = "";
            end
            obj.setValue(input);
        end
    end

    % aod.specification.Decorator methods
    methods
        function setValue(obj, input)
            if aod.util.isempty(input) || input == "[]"
                obj.Value = "";
                return
            end

            if isa(input, 'meta.property')
                input = input.Description;
            end

            input = convertCharsToStrings(input);
            mustBeTextScalar(input);

            obj.Value = input;
        end

        function output = text(obj)
            if isempty(obj)
                output = "[]";
            else
                output = obj.Value;
            end
        end
    end

    % MATLAB built-in methods
    methods
        function out = jsonencode(obj)
            if isempty(obj)
                out = jsonencode([]);
            else
                out = jsonencode(obj.Value);
            end
        end
    end
end