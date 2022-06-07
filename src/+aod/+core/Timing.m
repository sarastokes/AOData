classdef Timing < handle
% TIMING
%
% Description:
%   Provides a consistent interface for timing stored in different formats
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

    properties (Hidden, Dependent)
        Time
    end

    methods (Abstract, Access = protected)
        T = getTiming(obj)  % Subclasses define how to return timing
    end

    methods
        function obj = Timing(varargin)
            % Do nothing
        end

        function value = get.Time(obj)
            value = obj.getTiming();
        end
    end
end 

