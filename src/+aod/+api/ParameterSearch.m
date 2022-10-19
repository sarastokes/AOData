classdef ParameterSearch < handle

    properties
        paramName
    end

    methods 
        function obj = ParameterSearch(paramName, returnType)
            obj.paramName = paramName;
            obj.returnType = aod.api.ReturnTypes.init(returnType);
        end
    end
end