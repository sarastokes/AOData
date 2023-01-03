classdef PMT < aod.core.Device
% PMT
%
% Description:
%   A PMT within the system
%
% Parent:
%   aod.core.Device
%
% Constructor:
%   obj = aod.builtin.devices.PMT(name)
%   obj = aod.builtin.devices.PMT(name, 'Manufacturer', value, 'Model', value);

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = PMT(name, varargin)
            obj = obj@aod.core.Device(name, varargin{:});
        end
    end

    
    methods (Access = protected)
        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.core.Device(obj);
            
            value.add('SerialNumber', [], [],... 
                'Serial number of the light source');
            value.add('Position', [], @(x) numel(x) == 3,...
                'Optimized XYZ position of the PMT')
        end
    end
end 