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
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
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

            obj.setParam(ip.Results);
        end
    end
end 