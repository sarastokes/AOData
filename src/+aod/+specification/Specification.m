classdef (Abstract) Specification < handle & matlab.mixin.Heterogeneous

    methods (Abstract)
        out = text(obj)
        setValue(obj, input)
    end

    methods
        function obj = Specification()
        end
    end
end