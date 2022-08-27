classdef Registration < aod.core.Entity & matlab.mixin.Heterogeneous
% REGISTRATION
%
% Description:
%   Class for registration of images/videos
%
% Constructor:
%   obj = Registration(parent, data)
%
% Abstract methods:
%   varargout = apply(obj, varargin)
%
% Sealed methods:
%   setRegistrationDate(obj, regDate)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        registrationDate(1,1)               datetime
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Epoch'};
    end

    methods (Abstract)
        varargout = apply(obj, varargin)
    end

    methods
        function obj = Registration(registrationDate)
            obj = obj@aod.core.Entity();
            obj.setRegistrationDate(registrationDate);
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
            if isempty(regDate)
                return
            end
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