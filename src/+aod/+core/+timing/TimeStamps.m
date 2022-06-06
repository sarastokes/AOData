classdef TimeStamps < aod.core.Timing 
% TIMESTAMPS
%
% Description:
%   Individually sampled time points without a consistent interval
%
% Constructor:
%   obj = TimeStamps(timestamps)
%
% Inputs:
%   timestamps          Time of each sample in seconds
%--------------------------------------------------------------------------

    properties (SetAccess = private)
        timestamps
    end

    methods 
        function obj = TimeStamps(data)
            obj.timestamps = data;
        end
    end

    methods (Access = protected)
        function value = getTiming(obj)
            value = obj.timestamps;
        end
    end
end 