classdef DefaultValue < aod.specification.Validator 

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value           = []
    end

    methods
        function obj = DefaultValue(input)
            if nargin > 0
                obj.setValue(input);
            end
        end
    end

    methods 
        function setValue(obj, input)
            if isa(input, 'meta.property')
                if input.HasDefault
                    obj.Value = input.DefaultValue;
                end
            else
                obj.Value = input;
            end
        end

        function tf = validate(~, ~)
            tf = true;
        end

        function out = text(obj)
            out = value2string(obj.Value);
        end
    end

    % MATLAB built-in methods
    methods 
        function tf = isempty(obj)
            tf = aod.util.isempty(obj.Value);
        end
    end
end