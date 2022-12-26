classdef SpatialAverage < aod.builtin.responses.SpatialAverage 
% The average response at each pixel 
%
% Description:
%   Takes the average at each time point, across the full imaging window
%

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    methods
        function obj = SpatialAverage(parent, varargin)
            obj@aod.builtin.responses.SpatialAverage('SpatialAverage', parent);
            obj.extractResponse(varargin{:});
        end

        function imStack = loadData(obj)
            imStack = obj.Parent.getStack();
        end
    end
end