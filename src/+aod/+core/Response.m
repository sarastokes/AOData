classdef Response < aod.core.Entity
% RESPONSE
%
% Description:
%   A response measured over time
%
% Properties:
%   Data 
%   responseParameters
%
% Methods:
%   addParameter(obj, paramValue, paramName)
%   setData(obj, data)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Data                            timetable
        responseParameters              % aod.core.parameters
    end

    methods
        function obj = Response(parent)
            obj.allowableParentTypes = {'aod.core.Epoch', 'aod.core.Empty'};
            if nargin > 0
                obj.addParent(parent);
            end
            obj.responseParameters = aod.core.Parameters();
        end

        function setData(obj, data)
            % SETDATA
            %
            % Syntax:
            %   setData(obj, data)
            % -------------------------------------------------------------
            obj.Data = data;
        end

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