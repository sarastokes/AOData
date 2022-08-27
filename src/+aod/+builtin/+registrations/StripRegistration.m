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
% Inputs:
%   registrationDate                    
%
% Properties:
%   usedFrame (logical; whether strip or frame reg was ultimately used)
%
% -------------------------------------------------------------------------

    properties
        usedFrame(1,1)       logical = false
    end

    properties (SetAccess = protected)
        corrCoef 
        regFlag 
        stripX 
        stripY
        frameXY
        regDescription
        extraCol
    end

    methods
        function obj = StripRegistration(registrationDate, usedFrame)
            if nargin == 0
                registrationDate = [];
            end
            obj@aod.core.Registration(registrationDate);
            if nargin > 1
                obj.usedFrame = usedFrame;
            end
        end

        function apply(~)
            warning("StripRegistration:AlreadyApplied",... 
                "Strip Registration is applied offline");
        end

        function setUsedFrame(obj, tf)
            obj.usedFrame = tf;
        end

        function loadData(obj, fPath, ID)
            % LOADDATA
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
            S = reader.read();

            [S, hasFrame] = extractField(S, 'hasFrame');
            obj.setParam('Frame', hasFrame);
            [S, hasStrip] = extractField(S, 'hasStrip');
            obj.setParam('Strip', hasStrip);

            % Assign the remaining values as properties
            f = string(fieldnames(S));
            for i = 1:numel(f)
                obj.(f(i)) = S.(f(i));
            end
            obj.setFile('RegistrationOutput', reader.fullFile);
        end

        function loadParameters(obj, fPath, ID)
            if nargin < 3
                reader = aod.builtin.readers.RegistrationParameterReader(fPath);
            else
                reader = aod.builtin.readers.RegistrationParameterReader.init(fPath, ID);
            end
            obj.setParam(reader.read());
            obj.setFile('RegistrationParameters', reader.fullFile);
        end
    end
end 