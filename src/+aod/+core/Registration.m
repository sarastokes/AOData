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
% Properties:
%   registrationDate        datetime
%       Date registration was performed
%
% Attributes:
%   Administrator           string
%       Person(s) who performed the registration
%   Software                string
%       Software used to perform the registration
%
% Sealed methods:
%   setDate(obj, regDate)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % The date the registration was performed
        registrationDate    datetime    {mustBeScalarOrEmpty} = datetime.empty()
    end

    methods
        function obj = Registration(name, registrationDate, varargin)
            obj@aod.core.Entity(name, varargin{:});
            if nargin > 1
                obj.setDate(registrationDate);
            end
        end
    end

    methods (Sealed)
        function setDate(obj, regDate)
            % Set the date where the registration was performed
            % 
            % Syntax:
            %   obj.setDate(regDate)
            %
            % Inputs:
            %   regDate             datetime, or char: 'yyyyMMdd'
            % -------------------------------------------------------------
            
            if ~isscalar(obj)
                arrayfun(@(x) setDate(x, regDate), obj);
                return
            end

            if nargin < 2 || isempty(regDate)
                obj.registrationDate = datetime.empty();
                return
            end

            regDate = aod.util.validateDate(regDate);
            obj.registrationDate = regDate;
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();

            value.add('Administrator', string.empty(), @istext,... 
                "Person(s) who performed the registration");
            value.add('Software', string.empty(), @isstring,...
                "Software used for the registration")
        end
    end
end