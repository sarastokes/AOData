classdef Empty < aod.core.Calibration
% EMPTY
%
% Description:
%   An empty calibration object
%
% Parent:
%   aod.core.Calibration
%
% Constructor:
%   obj = aod.core.calibrations.Empty()
%   obj = aod.core.calibrations.Empty(parent)
% -------------------------------------------------------------------------
    methods
        function obj = Empty(parent)
            obj = obj@aod.core.Calibration(parent);
            calibrationDate = datestr(now);
            if nargin < 1
                parent = [];
            end
            obj = obj@aod.core.Calibration(calibrationDate, parent);

            obj.setDescription('An empty calibration object');
        end
    end
end