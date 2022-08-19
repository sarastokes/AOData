classdef Response < aod.core.Entity & matlab.mixin.Heterogeneous
% RESPONSE
%
% Description:
%   A response measured during an Epoch
%
% Parent: 
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Properties:
%   Data 
%   responseParameters
%   dateCreated
%
% Dependent properties:
%   Experiment 
%
% Methods:
%   setData(obj, data)
%   setTiming(obj, timing)
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data                             
        Timing                              aod.core.Timing
        responseParameters                  = aod.core.Parameters
    end

    properties (Hidden, Dependent)
        Experiment
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Epoch'};
        parameterPropertyName = 'responseParameters';
    end

    methods
        function obj = Response(parent)
            obj = obj@aod.core.Entity(parent);
        end

        function value = get.Experiment(obj)
            value = obj.ancestor('aod.core.Experiment');
        end
    end

    methods (Sealed)
        function setData(obj, data)
            % SETDATA
            %
            % Syntax:
            %   setData(obj, data)
            % -------------------------------------------------------------
            obj.Data = data;
        end

        function setTiming(obj, timing)
            % SETTIMING
            %
            % Syntax:
            %   obj.setTiming(timing)
            % -------------------------------------------------------------
            obj.Timing = timing;
        end
    end
end