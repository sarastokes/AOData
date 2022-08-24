classdef TimeRate < aod.core.Timing 
% TIMERATE
%
% Description:
%   Consistent timing that can be descibed by 2-3 numbers
%
% Parent:
%   aod.core.Timing
%
% Constructor:
%   obj = TimeRate(timeInterval, timeCount)
%   obj = TimeRate(timeInterval, timeCount, timeStart)
%
% Inputs:
%   parent                  aod.core.Response or []
%   timeInterval            time interval in seconds
%   timeCount               number of points
% Optional inputs:
%   timeStart               start time in seconds, default = 0
%
% Properties:
%   Interval 
%   Start
%   Count
%
% Note:
%   Units for time are seconds!
%--------------------------------------------------------------------------

    properties (SetAccess = private)
        Interval(1,1)   double      {mustBePositive}                   = 1
        Start(1,1)      double                                         = 0
        Count(1,1)      double      {mustBeInteger, mustBeNonnegative} = 0
    end

    methods 
        function obj = TimeRate(timeInterval, timeCount, timeStart)
            obj = obj@aod.core.Timing();
            obj.Interval = timeInterval;
            obj.Count = timeCount;

            if nargin > 2
                obj.Start = timeStart;
            else
                obj.Start = obj.Interval;
            end
        end
    end

    methods (Access = protected)
        function value = getTiming(obj)
            if isempty(obj.Count) || obj.Count == 0
                value = [];
                return
            end
            stopTime = (obj.Interval * (obj.Count));
            value = obj.Interval:obj.Interval:stopTime;
            value = value + obj.Start;
        end
    end
end