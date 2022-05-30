classdef StripRegistration < aod.core.Registration
% STRIPREGISTRATION
%
% Description:
%   Imager software registration
%
% Properties:
%   usedFrame (logical; whether strip or frame reg was ultimately used)
% -------------------------------------------------------------------------

    properties
        usedFrame(1,1)       logical = false
    end

    methods
        function obj = StripRegistration(parent)
            obj@aod.core.Registration(parent);

            obj.tryLoad();
        end

        function loadData(obj, fName)
            % LOADDATA
            % 
            % Syntax:
            %   obj.loadData(fName)
            % -------------------------------------------------------------
            if nargin < 2
                fName = obj.Parent.getFilePath('RegistrationReport');
            end
            reader = aod.builtin.readers.RegistrationReportReader(fName);
            obj.Data = reader.read();
        end

        function loadParameters(obj, fName)
            if nargin < 2
                fName = obj.Parent.getFilePath('RegistrationParameters');
            end
            reader = aod.builtin.readers.RegistrationParameterReader(fName);
        end

    end

    methods (Access = private)
        function tryLoad(obj)
            % try
                obj.loadData();
                obj.loadParameters();
            % catch
                % Do nothing
            % end
        end
    end
end 