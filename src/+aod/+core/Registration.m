classdef Registration < aod.core.Entity & matlab.mixin.Heterogeneous
% REGISTRATION
%
% Description:
%   Class for registration of images/videos
%
% Constructor:
%   obj = Registration(parent, data)
%
% Sealed methods:
%   setRegistrationDate(obj, regDate)
%
% Inherited methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data
        registrationDate(1,1)               datetime
        registrationParameters              = aod.core.Parameters
    end

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Epoch'};
        parameterPropertyName = 'registrationParameters';
    end

    % TODO: Add setData method?
    methods (Abstract)
        varargout = apply(obj, varargin)
    end

    methods
        function obj = Registration(parent, data)
            obj = obj@aod.core.Entity(parent);

            if nargin > 1
                obj.Data = data;
            end
        end
    end

    methods (Sealed)
        function setRegistrationDate(obj, regDate)
            % SETREGISTRATIONDATE
            %
            % Description:
            %   Set the date where the registration was performed
            % 
            % Syntax:
            %   obj.setRegistrationDate(regDate)
            %
            % Inputs:
            %   regDate             datetime, or char: 'yyyyMMdd'
            % -------------------------------------------------------------
            if ~isdatetime(regDate)
                try
                    regDate = datetime(regDate, 'Format', 'yyyyMMdd');
                catch ME 
                    if strcmp(ME.id, 'MATLAB:datestr:ConvertToDateNumber')
                        error("setRegistrationDate:FailedDatetimeConversion",...
                            "Failed to convert to datetime, use format yyyyMMdd");
                    else
                        rethrow(ME);
                    end
                end
            end
            obj.registrationDate = regDate;
        end
    end
end