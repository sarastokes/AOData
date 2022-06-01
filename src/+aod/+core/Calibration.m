classdef (Abstract) Calibration < aod.core.Entity
% CALIBRATION
%
% Constructor:
%   obj = aod.core.Calibration(calibrationDate, parent)
%
% Properties:
%   calibrationDate         date when the calibration was performed
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        calibrationDate(1,1) datetime
    end

    methods
        function obj = Calibration(calibrationDate, parent)
            obj.allowableParentTypes = {'aod.core.Dataset', 'aod.core.System', 'aod.core.Empty'};
            
            if nargin > 0 && ~isempty(calibrationDate)
                if ~isa(calibrationDate, 'datetime')
                    obj.calibrationDate = datetime(calDate, 'Format', 'yyyyMMdd');
                else
                    obj.calibrationDate = calibrationDate;
                end
            end

            if nargin > 1 && ~isempty(parent)
                obj.setParent(parent);
            end
        end
    end
end

