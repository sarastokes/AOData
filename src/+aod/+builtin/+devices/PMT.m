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
% Attributes:
%   SerialNumber            string
% Inherited Attributes:
%   Manufacturer
%   Model

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = PMT(name, varargin)
            obj = obj@aod.core.Device(name, varargin{:});
        end
    end

    
    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add("SerialNumber",...
                "Class", "string", "Size", "(1,1)",...
                "Description", "Serial number of the light source");
        end
    end
end 