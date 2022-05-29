classdef (Abstract) Response < aod.core.Entity

    properties (SetAccess = private)
        Data 
        responseParameters
    end

    methods
        function obj = Response(parent)
            obj.allowableParentTypes = {'aod.core.Epoch'};
            if nargin > 0
                obj.addParent(parent);
            end
            obj.responseParameters = containers.Map();
        end


        function value = getParameter(obj, paramName)
            % GETPARAMETER
            %
            % Syntax:
            %   value = obj.getParameter(paramName)
            % -------------------------------------------------------------
            if ~isKey(obj.parameters, paramName)
                error('Parameter %s not found!', paramName);
            end
            value = obj.parameter(paramName);
        end
    end

    methods (Access = protected)
        function addParameter(obj, paramName, paramValue)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, paramValue)
            % -------------------------------------------------------------
            obj.responseParameters(paramName) = paramValue;
        end
    end
end