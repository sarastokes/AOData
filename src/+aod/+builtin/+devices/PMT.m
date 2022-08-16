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
%   obj = PMT(parent, varargin)
%
% Parameters:
%   Gain
%   Position
% Inherited parameters:
%   Manufacturer
%   Model
%
% Methods:
%   setGain(obj, gain)
%   setPosition(obj, position)
% -------------------------------------------------------------------------

    methods 
        function obj = PMT(parent, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});
            
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'Gain', [], @isnumeric);
            addParameter(ip, 'Position', [], @isnumeric);
            parse(ip, varargin{:});

            obj.addParameter(ip.Results);
        end
    end
    
    methods
        function setPosition(obj, position)
            obj.deviceParameters('Position') = position;
        end
        
        function setGain(obj, gain)
            obj.deviceParameters('Gain') = gain;
        end
    end
end 