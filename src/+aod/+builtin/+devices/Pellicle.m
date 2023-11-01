classdef Pellicle < aod.builtin.devices.Beamsplitter
% A pellicle beamsplitter
%
% Superclasses:
%   aod.builtin.devices.Beamsplitter
%
% Constructor:
%   obj = aod.builtin.devices.Pellicle(name, splittingRatio)
%   obj = aod.builtin.devices.Pellicle(name, splittingRatio, varargin)
%
% Properties:
%   reflectance
%   transmission
%
% Attributes:
%   SplittingRatio
%   Manufacturer
%   Model

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Pellicle(splittingRatio, varargin)
            obj@aod.builtin.devices.Beamsplitter(splittingRatio, varargin{:});
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = sprintf("%u:%uPellicle", obj.getAttr('SplittingRatio'));
        end
    end

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "e739df1f-62d5-46ab-aba7-d8c7bf173261";
		end
    end
end