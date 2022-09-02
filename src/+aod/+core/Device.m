classdef Device < aod.core.Entity & matlab.mixin.Heterogeneous
% DEVICE
%
% Description:
%   A light source, NDF, filter, PMT, etc used in an experiment
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Device(varargin)
%
% Parameters:
%   Model                               Model of the device
%   Manufacturer                        Manufacturer of the device
%
% Public Sealed methods:
%   assignUUID(obj, uuid)
%
% Inherited methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------
    
    methods
        function obj = Device(name, varargin)
            obj = obj@aod.core.Entity(name);
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Model', [], @ischar);
            addParameter(ip, 'Manufacturer', [], @ischar);
            parse(ip, varargin{:});
            
            obj.setParam(ip.Results);
        end
    end
    
    methods (Sealed)
        function assignUUID(obj, UUID)
            % ASSIGNUUID
            %
            % Description:
            %   The same devices may be used over multiple experiments and
            %   should share UUIDs. This function provides public access
            %   to aod.core.Entity's setUUID function to facilitate hard-
            %   coded UUIDs for common sources
            %
            % Syntax:
            %   obj.assignUUID(UUID)
            %
            % See also:
            %   aod.util.generateUUID
            % -------------------------------------------------------------
            obj.setUUID(UUID);
        end
    end
end