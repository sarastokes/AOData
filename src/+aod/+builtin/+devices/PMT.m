classdef PMT < aod.core.Device
% A photomultiplier tube
%
% Description:
%   A PMT used to acquire data
%
% Parent:
%   aod.core.Device
%
% Constructor:
%   obj = aod.builtin.devices.PMT(name)
%   obj = aod.builtin.devices.PMT(name, 'SerialNumber', "value",...
%       'Manufacturer', "value", 'Model', "value");
%
% Parameters:
%   SerialNumber            string
% Inherited Parameters:
%   Manufacturer
%   Model

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = PMT(name, varargin)
            obj = obj@aod.core.Device(name, varargin{:});
        end
    end

    
    methods (Access = protected)
        function value = specifyParameters(obj)
            value = specifyParameters@aod.core.Device(obj);
            
            value.add('SerialNumber', [], @isstring,... 
                'Serial number of the light source');
        end
    end
end 