classdef TimeRate < aod.core.Timing 
% TIMERATE
%
% Description:
%   Consistent timing that can be descibed by 2-3 numbers
%
% Constructor:
%   obj = TimeRate(timeInterval, timeCount, timeStart)
%
% Inputs:
%   timeInterval            time interval in seconds
%   timeCount               number of points
% Optional inputs:
%   timeStart               start time in seconds, default = 0
%
% Note:
%   Units for time are seconds!
%--------------------------------------------------------------------------

    properties (SetAccess = private)
        timeInterval(1,1) double = 1
        timeStart(1,1) double = 0
        timeCount(1,1)  double
    end

    methods 
        function obj = TimeRate(timeInterval, timeCount, timeStart)
            if nargin > 0 
                obj.timeInterval = timeInterval;
                obj.timeCount = timeCount;
            end

            if nargin > 2
                obj.timeStart = timeStart;
            end
        end
    end

    methods (Access = private)
        function value = getTiming(obj)
            if isempty(obj.timeCount) || obj.timeCount = 0
                value = [];
                return
            end
            stopTime = (timeInterval * timeCount) - timeStart;
            value = timeStart:timeInterval:stopTime;
        end
    end
end