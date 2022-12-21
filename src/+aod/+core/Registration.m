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
% Sealed methods:
%   setRegistrationDate(obj, regDate)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        registrationDate                datetime = datetime.empty()
    end

    methods
        function obj = Registration(name, registrationDate, varargin)
            obj@aod.core.Entity(name, varargin{:});
            if nargin > 1
                obj.setRegistrationDate(registrationDate);
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
            if nargin < 2 || isempty(regDate)
                obj.registrationDate = datetime.empty();
                return
            end

            regDate = aod.util.validateDate(regDate);
            obj.registrationDate = regDate;
        end
    end
end