classdef DichroicFilter < aod.core.Device
% A dichroic filter within a system
%
% Parent:
%   aod.core.Device
%
% Constructor:
%   obj = DichroicFilter(wavelength, passType, varargin)
%   
% Attributes:
%   Wavelength                      numeric
%   PassType                        char, 'low' or 'high'
% Inherited Attributes:
%   Manufacturer
%   Model
%
% Properties:
%   transmission
%
% Methods:
%   setWavelength(obj, wavelength)
%   setTransmission(obj, spectrum)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        transmission         
    end
    
    methods
        function obj = DichroicFilter(wavelength, passType, varargin)
            obj = obj@aod.core.Device([], varargin{:});
            
            obj.setWavelength(wavelength);
            obj.setPassType(passType);
        end
    end
    
    methods
        function setWavelength(obj, wavelength)
            % Set the cutoff wavelength for the filter
            %
            % Syntax:
            %   setWavelength(obj, wavelength)
            % -------------------------------------------------------------
            assert(isnumeric(wavelength),  'Wavelength must be a number')
            obj.setAttr('Wavelength', wavelength);
        end
        
        function setPassType(obj, passType)
            % Change the pass type of the filter
            %
            % Syntax:
            %   setPassType(obj, passType)
            %
            % Inputs:
            %   passType        string
            %       Must be either "low" or "high"
            % -------------------------------------------------------------
            passType = lower(passType);
            assert(ismember(passType, {'low', 'high'}),...
                'PassType must be either ''low'' or ''high''');
            obj.setAttr('Pass', passType);
        end

        function setTransmission(obj, spectra)
            % Set the dichroic filter's transmission
            %
            % Syntax:
            %   setSpectrum(obj, spectrum)
            % -------------------------------------------------------------
            obj.transmission = spectra;
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = sprintf('%unm%sPassFilter',... 
                obj.getAttr('Wavelength'),...
                appbox.capitalize(obj.getAttr('Pass')));
        end
    end

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Device(value);

            value.set("transmission",...
                "Class", "double", "Size", "(:,2)",...
                "Units", ["nm", "%"],...
                "Description", "Transmission spectra of filter");
        end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add("Wavelength",...
                "Class", "double", "Size", "(1,1)", "Units", "nm",...
                "Description", "The cutoff wavelength of the filter");
            value.add("Pass",...
                "Class", "string", "Size", "(1,1)",...
                "Function", @(x) mustBeMember(x, ["low", "high"]),...
                "Description", "Whether the dichroic is low or high pass");
        end
    end
end