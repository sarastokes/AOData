classdef Empty < aod.core.Calibration
% EMPTY
%
% Description:
%   An empty placeholder calibration object
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
            calibrationDate = datestr(now);
            if nargin < 1
                parent = [];
            end
            obj = obj@aod.core.Calibration(parent, calibrationDate);

            obj.setDescription('A placeholder calibration object');
        end
    end
end