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
% Properties:
%   gain
%   position
% Inherited properties:
%   manufacturer
%   models
%
% Methods:
%   setGain(obj, gain)
%   setPosition(obj, position)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        gain
        position
    end

    methods 
        function obj = PMT(parent, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});
            
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'Gain', [], @isnumeric);
            addParameter(ip, 'Position', [], @isnumeric);
            parse(ip, varargin{:});
        end
    end
    
    methods
        function setPosition(obj, position)
            obj.position = position;
        end
        
        function setGain(obj, gain)
            obj.gain = gain;
        end
    end
end 