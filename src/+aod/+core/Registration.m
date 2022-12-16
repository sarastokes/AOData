classdef Registration < aod.core.Entity & matlab.mixin.Heterogeneous
% REGISTRATION
%
% Description:
%   Any correction applied to the acquired data
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.Registration(parent, data)
%
% Abstract methods:
%   varargout = apply(obj, varargin)
%
% Sealed methods:
%   setRegistrationDate(obj, regDate)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        registrationDate(1,1)               datetime
    end
    
    methods (Abstract)
        varargout = apply(obj, varargin)
    end

    methods
        function obj = Registration(name, registrationDate)
            obj = obj@aod.core.Entity(name);
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
            regDate = aod.util.validateDate(regDate);
            obj.registrationDate = regDate;
        end
    end
end