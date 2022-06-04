classdef Response < aod.core.Entity
% RESPONSE
%
% Description:
%   A response measured over time
%
% Properties:
%   Data 
%   responseParameters
%   dateModified
% Dependent properties:
%   Dataset 
%
% Methods:
%   addParameter(obj, paramValue, paramName)
%   setData(obj, data)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data                            timetable
        responseParameters              % aod.core.parameters
        dateModified                    % date and time last modified
    end

    properties (Hidden, Dependent)
        Dataset
    end

    methods
        function obj = Response(parent)
            obj.allowableParentTypes = {'aod.core.Epoch'};
            if nargin > 0
                obj.setParent(parent);
            end
            obj.responseParameters = aod.core.Parameters();
            obj.dateModified = datestr(now);
        end

        function value = get.Dataset(obj)
            value = obj.ancestor('aod.core.Dataset');
        end

        function setData(obj, data)
            % SETDATA
            %
            % Syntax:
            %   setData(obj, data)
            % -------------------------------------------------------------
            obj.Data_ = data;
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