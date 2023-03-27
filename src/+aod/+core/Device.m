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
%   Model                            string   
%       Model of the device
%   Manufacturer                     string  
%       Manufacturer of the device

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    methods
        function obj = Device(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
        end
    end

    methods (Access = protected)
        function value = specifyParameters(obj)
            value = specifyParameters@aod.core.Entity(obj);

            value.add('Manufacturer', [], @isstring,... 
                "The company that made the device");
            value.add('Model', [], @isstring,... 
                "The model number of the device");
        end
    end
end