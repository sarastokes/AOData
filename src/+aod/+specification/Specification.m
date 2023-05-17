classdef Specification < handle & matlab.mixin.Heterogeneous

    properties (SetAccess = protected)
        Value 
    end

    methods (Abstract)
        tf = validate(obj, input)
        out = text(obj)
    end

    methods
        function obj = Specification()
        end
    end
end