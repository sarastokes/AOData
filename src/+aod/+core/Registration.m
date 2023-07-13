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

    properties (SetObservable, SetAccess = protected)
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
            obj.setProp('registrationDate', regDate);
        end
    end

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Entity(value);

            value.set("registrationDate",...
                "Class", "datetime", "Size", "(1,1)",...
                "Description", "Date the registration was performed");
        end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();

            value.add("Administrator",...
                "Class", "string", "Size", "(1,1)",...
                "Description", "Person(s) who performed the registration");
            value.add("Software",...
                "Class", "string", "Size", "(1,1)",...
                "Description", "Software used for the registration");
        end
    end
end