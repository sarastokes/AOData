classdef ExpectedParameter < handle
% Represents a MATLAB key/value input to parameters, mapping to attributes
%
% Constructor:
%   obj = aod.util.templates.ExpectedParameter(name)
%   obj = aod.util.templats.ExpectedParameter(name,...
%       defaultValue, validationFcn, description)
%
% See also:
%   aod.util.ParameterManager

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties
        % The parameter name in upper camelCase (e.g. MyParamName)
        Name            char
        % Default value for the parameter
        Default                                                     = []
        % Anonymous function handle for validating input
        Validation                                                  = []
        % Information about the property such as units
        Description     string                                      = string.empty()
    end

    methods
        function obj = ExpectedParameter(name, defaultValue, validationFcn, description)
            obj.Name = name;

            if nargin > 1 && ~isempty(defaultValue)
                obj.Default = defaultValue;
            end

            if nargin > 2 && ~isempty(validationFcn)
                obj.Validation = validationFcn;
            end

            if nargin > 3 && ~isempty(description)
                obj.Description = description;
            end
        end

        function set.Validation(obj, value)
            if isempty(value)
                obj.Validation = [];
                return
            end

            if ~isa(value, 'function_handle')
                error('ExpectedParameter:InvalidFunction',...
                    '"validationFcn" must be a function handle');
            end
            obj.Validation = value;
        end

        function ip = addToParser(obj, ip)
            if isempty(obj.Validation)
                addParameter(ip, obj.Name, obj.Default);
            else
                addParameter(ip, obj.Name, obj.Default, obj.Validation);
            end
        end
    end

    % Built-in MATLAB methods
    methods 
        function tf = isequal(obj, other)
            % Tests for equality.
            %
            % Description:
            %   Two ExpectedParameter objects are considered equal if they 
            %   have the same name (case-insensitive). If the second input 
            %   is not an ExpectedParameter, it is not equal
            %
            % Syntax:
            %   tf = isequal(obj, other)
            % -------------------------------------------------------------

            if ~isscalar(other)
                tf = aod.util.arrayfun(@(x) isequal(obj, x), other);
                return
            end

            if ~isa(other, 'ExpectedParameter')
                tf = false;
                return
            end

            if ~strcmp(obj.Name, other.Name)
                tf = false;
            else
                tf = true;
            end
        end
    end
end 