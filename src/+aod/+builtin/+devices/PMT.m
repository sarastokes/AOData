classdef PMT < aod.core.Device
% PMT
%
% Description:
%   A PMT within the system
%
% Parent:
%   aod.core.Device
%
% Parameters:
%   Position
%
% Constructor:
%   obj = PMT(name, varargin)
% -------------------------------------------------------------------------

    methods 
        function obj = PMT(name, varargin)
            obj = obj@aod.core.Device(varargin{:});
            obj.setName(name);
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Position', [], @isnumeric);
            parse(ip, varargin{:});

            obj.setParam(ip.Results);
        end
    end
end 