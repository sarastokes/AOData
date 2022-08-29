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
%   obj = PMT(name)
%   obj = PMT(name, 'Manufacturer', value, 'Model', value);
%
% Optional Parameters:
%   Position
%   Gain
%
% Constructor:
%   obj = PMT(name, varargin)
% -------------------------------------------------------------------------

    methods 
        function obj = PMT(name, varargin)
            obj = obj@aod.core.Device(name, varargin{:});
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Position', [], @isnumeric);
            addParameter(ip, 'Gain', [], @isnumeric);
            parse(ip, varargin{:});

            obj.setParam(ip.Results);
        end
    end
end 