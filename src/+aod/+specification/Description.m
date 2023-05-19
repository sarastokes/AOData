classdef Description < aod.specification.Descriptor 
%
% Constructor:
%   aod.specification.Description

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value (1,1)         string      = ""
    end

    methods
        function obj = Description(input)
            obj = obj@aod.specification.Descriptor(input);
        end

        function output = text(obj)
            output = obj.Value;
        end
    end

    methods (Access = protected)
        function assign(obj, input)
            input = convertCharsToStrings(input);
            obj.Value = input;
        end
    end

    methods (Static)
        function obj = get(obj, className, propName)
            if istext(input)
                mc = meta.class.fromName(input);
            elseif ~isa(mc, 'meta.class')
                mc = metaclass(mc);
            end

            idx = find(arrayfun(@(x) strcmp(x.Name, propName), mc.PropertyList));

            if isempty(idx)
                error("getClassPropDescription:PropertyNotFound", ...
                    "Property %s not found", propName);
            end

            value = mc.PropertyList(idx).Description;

            obj = aod.specification.Description(value);
        end
    end
end 