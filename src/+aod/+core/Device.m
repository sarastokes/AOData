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
% Attributes:
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

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "756660d3-f2a9-40b3-8ed6-b2f26d17c3e1";
		end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();

            value.add("Manufacturer", "TEXT",...
                "Size", "(1,1)",...
                "Description", "The company that made the device");
            value.add("Model", "TEXT",...
                "Size", "(1,1)",...
                "Description", "The model of the device");
        end
    end
end