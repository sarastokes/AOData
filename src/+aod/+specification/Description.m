classdef Description < aod.specification.Descriptor 
%
% Superclass:
%   aod.specification.Descriptor
%
% Constructor:
%   obj = aod.specification.Description(input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value (1,1)         string      = ""
    end

    methods
        function obj = Description(input)
            if nargin < 1 || aod.util.isempty(input) || input == "[]"
                input = "";
            end
            obj.setValue(input);
        end
    end

    % aod.specification.Descriptor methods
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