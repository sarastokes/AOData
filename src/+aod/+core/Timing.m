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
% Dependent properties:
%   Time                    Time of each sample in seconds
%
% Abstract methods:
%   T = getTiming(obj)
% -------------------------------------------------------------------------

    properties (Dependent)
        Time
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Epoch', 'aod.core.Response'}
    end

    methods (Abstract, Access = protected)
        T = getTiming(obj)  % Subclasses define how to return timing
    end

    methods
        function obj = Timing(name)
            obj = obj@aod.core.Entity(name);
        end

        function value = get.Time(obj)
            value = obj.getTiming();
        end
    end
end 

