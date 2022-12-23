classdef Calibration < aod.core.Calibration 
% An empty Calibration
%
% Description:
%   An Empty Calibration to prevent UUID conflicts and flag the HDF5 
%   writing to skip the entity.
%
% Constructor:
%   obj = aod.core.empty.Calibration

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = Calibration()
            obj@aod.core.Calibration("Empty", []);
            obj.assignUUID("d18642a3-745a-4d63-ae26-3c8e1d87c944");
        end
    end
end 