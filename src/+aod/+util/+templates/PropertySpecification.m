classdef PropertySpecification < aod.util.templates.Specification
% Specification of a new property (HDF5 dataset)
%
% Parent:
%   aod.util.templates.Specification
%
% Constructor:
%   obj = aod.util.templates.PropertySpecification(name)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties
        % Property name (required)
        Name                string  {mustBeValidVariableName}
        % Class type requirements for the property (default = none)
        Class            string          = string.empty()
        % Default value for the property (default = none)
        Default 
        % Property get-access
        GetAccess        string  {mustBeMember(GetAccess, ["public", "private", "protected"])} = "public"
        % Property set access
        SetAccess        string  {mustBeMember(SetAccess, ["public", "private", "protected"])} = "protected"
    end

    methods
        function obj = PropertySpecification(name)
            obj.Name = name;
        end
    end

    methods
        function set.Class(obj, value)
            arguments
                obj
                value       string
            end

            if contains(value, ",")
                value = commalist2array(value);
            end

            goodClass = string.empty();
            badClass = string.empty();
            for i = 1:numel(value)
                if ~exist(value(i), 'class')
                    badClass = cat(1, badClass, value(i));
                else
                    goodClass = cat(1, goodClass, value(i));
                end
            end
            if ~isempty(goodClass)
                obj.Class = goodClass;
            end
            if ~isempty(badClass)
                error("setClass:InvalidClass",...
                    "Unrecognized class %s", badClass);
            end
        end
    end
end 