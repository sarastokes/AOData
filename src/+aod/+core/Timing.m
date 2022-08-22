classdef Timing < aod.core.Entity & matlab.mixin.Heterogeneous
% TIMING
%
% Description:
%   Provides a consistent interface for timing stored in different formats
% 
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Timing(varargin)
%
% Properties:
%   timingParameters
%
% Dependent properties:
%   Time                    Time of each sample in seconds
%
% Abstract methods:
%   T = getTiming(obj)
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------

    properties
        % timingParameters        = aod.core.Parameters
    end

    properties (Hidden, Dependent)
        Time
    end

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Response'}
        % parameterPropertyName = 'timingParameters'
    end

    methods (Abstract, Access = protected)
        T = getTiming(obj)  % Subclasses define how to return timing
    end

    methods
        function obj = Timing(parent)
            obj = obj@aod.core.Entity();
            if nargin > 0
                obj.setParent(parent);
            end
        end

        function value = get.Time(obj)
            value = obj.getTiming();
        end
    end
end 

