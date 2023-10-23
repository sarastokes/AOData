classdef Beamsplitter < aod.core.Device
% A beamsplitter
%
% Constructor:
%   obj = aod.builtin.devices.BeamSplitter(name, splittingRatio)
%   obj = aod.builtin.devices.BeamSplitter(name, splittingRatio, varargin)
%
% Properties:
%   reflectance
%   transmission
%
% Attributes:
%   SplittingRatio
%   Manufacturer
%   Model
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetObservable, SetAccess = {?aod.core.Entity})
        reflectance
        transmission
    end

    methods
        function obj = Beamsplitter(splittingRatio, varargin)
            obj = obj@aod.core.Device([], varargin{:});

            obj.setSplittingRatio(splittingRatio);
        end
    end

    methods
        function setSplittingRatio(obj, splittingRatio)
            obj.setAttr('SplittingRatio', splittingRatio);
        end

        function setReflectance(obj, value)
            % Set the beamsplitter reflectance
            %
            % Syntax:
            %   setReflectance(obj, value)
            %
            % Inputs:
            %   value           data or filename
            %       Column order: wavelength, reflectance
            % -------------------------------------------------------------
            obj.setProp('reflectance', value);
        end

        function setTransmission(obj, value)
            % Set the beamsplitter transmission
            %
            % Syntax:
            %   setTransmission(obj, value)
            %
            % Inputs:
            %   value           data or filename
            %       Column order: wavelength, transmission
            % -------------------------------------------------------------
            obj.setProp('transmission', value);
        end

        function setProperties(obj, value)
            % Set reflectance and transmission together (useful for data
            % imported from optics websites).
            %
            % Syntax:
            %   setBothTR(obj, value)
            %
            % Inputs:
            %   value           data or filename
            %       Column order: wavelength, reflectance, transmission
            % -------------------------------------------------------------

            if isfile(value)
                reader = aod.util.findFileReader(value);
                data = reader.readFile();
            else
                data = value;
            end
            obj.setProp('Reflectance', data(:,1:2));
            obj.setProp('Transmission', data(:, [1 3]));
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = sprintf("%u:%uBeamsplitter",...
                obj.getAttr('SplittingRatio'));
        end
    end

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Device(value);

            value.set("reflectance",...
                "Class", "double", "Size", "(:,2)", "Units", ["nm", "%"],...
                "Description", "Reflectance of the beamsplitter");
            value.set("transmission",...
                "Class", "double", "Size", "(:,2)", "Units", ["nm", "%"],...
                "Description", "Transmission of the beamsplitter");
        end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add("SplittingRatio", ...
                "Class", "double", "Size", "(1,2)", "Units", "%",...
                "Function", @(x) sum(x) == 100,...
                "Description", "The transmission and reflectance split");
        end
    end
end