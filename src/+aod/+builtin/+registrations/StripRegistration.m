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
%   obj = StripRegistration(parent)
%
% Inputs:
%   parent                      aod.core.Epoch, needed to extract file name
%
% Properties:
%   usedFrame (logical; whether strip or frame reg was ultimately used)
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------

    properties
        usedFrame(1,1)       logical = false
    end

    methods
        function obj = StripRegistration(parent)
            obj@aod.core.Registration(parent);

            obj.tryLoad();
        end

        function apply(~)
            warning("StripRegistration:AlreadyApplied",... 
                "Strip Registration is applied offline");
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
            obj.setParam(reader.read());
        end
    end

    methods (Access = private)
        function tryLoad(obj)
            try
                obj.loadData();
                obj.loadParameters();
            catch
                warning('Registration report or parameters not found');
            end
        end
    end
end 