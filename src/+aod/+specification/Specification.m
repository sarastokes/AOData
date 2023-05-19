classdef (Abstract) Specification < handle & matlab.mixin.Heterogeneous

    methods (Abstract)
        out = text(obj)
    end

    methods
        function obj = Specification()
        end
    end
end