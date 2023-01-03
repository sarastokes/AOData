classdef Device < aod.core.Entity & matlab.mixin.Heterogeneous
% A Device within an AO imaging System
%
% Description:
%   A light source, NDF, filter, PMT, etc used in an AO imaging experiment
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Device(varargin)
%
% Parameters:
%   Model                            char   
%       Model of the device
%   Manufacturer                     char  
%       Manufacturer of the device

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    methods
        function obj = Device(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
            
            %ip = aod.util.InputParser();
            %addParameter(ip, 'Model', [], @ischar);
            %addParameter(ip, 'Manufacturer', [], @ischar);
            %parse(ip, varargin{:});
            %ip = obj.expectedParameters.parse(varargin{:});
            %obj.setParam(ip.Results);
        end
    end

    methods (Access = protected)
        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.core.Entity(obj);

            value.add('Model', [], @ischar);
            value.add('Manufacturer', [], @ischar);
        end
    end
end