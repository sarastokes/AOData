classdef StripRegistration < aod.core.Registration
% STRIPREGISTRATION
%
% Description:
%   Registration performed with Qiang's registration software
%
% Parent:
%   aod.core.Registration
%
% Constructor:
%   obj = StripRegistration(registrationDate)
%
% Attributes:
%   RegistrationType        "frame" or "strip"
%       Whether the frame or strip registration was ultimately used                    
%
% Properties:
%   usedFrame (logical; whether strip or frame reg was ultimately used)
% Derived Properties:
%   corrCoef regFlag stripX stripY frameXY regDescription rotationAngle
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        corrCoef 
        regFlag 
        stripX 
        stripY
        frameXY
        regDescription
        rotationAngle
    end

    methods
        function obj = StripRegistration(name, registrationDate, varargin)
            if nargin < 1
                % There is often only one strip registration per Epoch 
                % so the class name (specifyLabel's default) may suffice
                name = [];
            end
            if nargin < 2
                registrationDate = [];
            end
            obj@aod.core.Registration(name, registrationDate, varargin{:});
            
            % Hard-coded attributes
            obj.setAttr('Software', "ImageReg");
        end

        function apply(~)
            warning("StripRegistration:AlreadyApplied",... 
                "Strip Registration is applied offline");
        end

        function loadData(obj, fPath, ID)
            % Load data from ImageReg strip registration
            % 
            % Syntax:
            %   obj.loadData(fName)
            %   obj.loadData(fPath, ID)
            % -------------------------------------------------------------
            if nargin < 3
                reader = aod.builtin.readers.RegistrationReportReader(fPath);
            else
                reader = aod.builtin.readers.RegistrationReportReader.init(fPath, ID);
            end
            S = reader.readFile();

            [S, hasFrame] = extractField(S, 'hasFrame');
            obj.setAttr('Frame', hasFrame);
            [S, hasStrip] = extractField(S, 'hasStrip');
            obj.setAttr('Strip', hasStrip);

            % Assign the remaining values as properties
            f = string(fieldnames(S));
            for i = 1:numel(f)
                obj.(f(i)) = S.(f(i));
            end

            % Record the file name used to extract the data
            obj.setFile('RegistrationOutput', reader.fullFile);
        end

        function loadParameters(obj, fPath, ID)
            % Load parameters from ImageReg strip registration
            % 
            % Syntax:
            %   obj.loadParameters(fName)
            %   obj.loadParameters(fPath, ID)
            % -------------------------------------------------------------
            if nargin < 3
                reader = aod.builtin.readers.RegistrationParameterReader(fPath);
            else
                reader = aod.builtin.readers.RegistrationParameterReader.init(fPath, ID);
            end
            obj.setAttr(reader.readFile());
            obj.setFile('RegistrationParameters', reader.fullFile);
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Registration();

            value.add('RegistrationType', [],... 
                @(x) ismember(x, ["frame", "strip"]),...
                "Whether frame or strip registration was used");
        end
    end
end 