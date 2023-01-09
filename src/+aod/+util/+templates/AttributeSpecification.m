classdef AttributeSpecification < aod.util.templates.Specification
% Specification of a new attribute
%
% Constructor:
%   obj = LinkSpecification(name, entityType)
%
% Parent:
%   Specification

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties
        % Property name (required)
        Name                string  {mustBeValidVariableName}
        % Default value for the property (default = none)
        Default
    end

    methods
        function obj = AttributeSpecification(name)
            obj.Name = name;

            % Key/value parameters are always optional by default
            obj.isOptional = true;
        end
    end

    methods
        function set.Name(obj, value)
            arguments
                obj
                value       string
            end

            obj.Name = capFirstChar(value);
        end
    end
end 