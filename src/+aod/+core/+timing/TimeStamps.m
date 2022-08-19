classdef TimeStamps < aod.core.Timing 
% TIMESTAMPS
%
% Description:
%   Individually sampled time points without a consistent interval
%
% Parent:
%   aod.core.Timing
%
% Constructor:
%   obj = TimeStamps(parent, timestamps)
%
% Inputs:
%   parent              aod.core.Response or []
%   timestamps          Time of each sample in seconds
%
% Note:
%   Units for time are seconds!
%--------------------------------------------------------------------------

    properties (SetAccess = private)
        timestamps
    end

    methods 
        function obj = TimeStamps(parent, data)
            obj = obj@aod.core.Timing(parent);
            obj.timestamps = data;
        end
    end

    methods (Access = protected)
        function value = getTiming(obj)
            value = obj.timestamps;
        end
    end
end 