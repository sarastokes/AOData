classdef Registration < aod.core.Entity

    properties (SetAccess = protected)
        Data
        registrationParameters
    end

    methods
        function obj = Registration(parent, data)
            obj.allowableParentTypes = {'aod.core.Epoch', 'aod.core.Empty'};
            if nargin > 0
                obj.setParent(parent);
            end
            if nargin > 1
                obj.Data = data;
            end
        end

        
        function setParameter(obj, paramName, paramValue)
            obj.registrationParameters(paramName) = paramValue;
        end

        function setParameters(obj, varargin)
            for i = 1:(nargin - 1)
                obj.setParameter(varargin{(2*i)-1}) = varargin{2*i};
            end
        end
    end
end