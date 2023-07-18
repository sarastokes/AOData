classdef StripRegistration < aod.core.Registration
% STRIPREGISTRATION
%
% Description:
%   Registration performed with Qiang's registration software
%
% Superclasses:
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

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        correlationCoefficient 
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
                obj.setProp(f(i), f(i));
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

            value.add("RegistrationType",...
                "Class", "string", "Size", "(1,1)",...
                "Function", @(x) ismember(x, ["frame", "strip"]),...
                "Description", "Whether frame or strip registration was chosen for subsequent processing.");
        end

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Registration();
            
            value.set("correlationCoefficient",...
                "Class", "double", "Size", "(:,1)",...
                "Description", "The correlation coefficient between each frame and the reference image");
            value.set("rotationAngle",...
                "Description", "The angle in degrees for torsion correction, per frame");
            value.set("frameXY",...
                "Class", "double", "Size", "(:,2)", "Units", "pixels",...
                "Description", "The X and Y offset from frame registration, per frame");
            value.set("stripX",...
                "Class", "double", "Units", "pixels",...
                "Description", "The X offsets for each registered strip, per frame");
            value.set("stripY", ...
                "Class", "double", "Units", "pixels", ...
                "Description", "The Y offsets for each registered strip, per frame");
            value.set("regDescription",...
                "Class", "string", "Size", "(:,1)",...
                "Description", "Whether registration succeeded or failed, per frame");
            value.set("regFlag",...
                "Class", "logical", "Size", "(:,1)",...
                "Description", "Whether registration failed");
        end
    end
end 