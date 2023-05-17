classdef Description < aod.specification.Specification 

    properties 
        Value   (1,1)       string = "[]"
    end

    methods 
        function obj = Description(value)
            if nargin > 1
                obj.Value = value;
            end
        end

        function tf = validate(obj, input)
            tf = true;
        end

        function out = text(obj)
            out = obj.Value;
        end
    end

    methods (Static)
        function out = get(input, propName)
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

            out = mc.PropertyList(idx).Description;
        end
    end
end 