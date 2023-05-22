classdef LinkSpecification < aod.util.templates.Specification
% Specification of a new property that is a link to another entity
%
% Constructor:
%   obj = LinkSpecification(name, entityType)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % aod.common.EntityTypes member (required)
        EntityType       % aod.common.EntityTypes member(s)   
    end

    properties (SetAccess = protected)
        % Default value for the property (default = none)
        Default  
    end
    
    properties (SetAccess = public)  
        % Property name (required)
        Name                string  {mustBeValidVariableName} 
        % Property get-access
        GetAccess        string  {mustBeMember(GetAccess, ["public", "private", "protected"])} = "public"
        % Property set access
        SetAccess        string  {mustBeMember(SetAccess, ["public", "private", "protected"])} = "protected"
    end

    methods
        function obj = LinkSpecification(name, entityType)
            obj.Name = name;
            obj.setEntityType(entityType);
        end
    end

    methods
        function setEntityType(obj, value)
            
            value = convertCharsToStrings(value);
            if contains(value, ",")
                value = commalist2array(value);
            end
            
            value = aod.util.arrayfun(@(x) aod.common.EntityTypes.get(x), value);

            obj.EntityType = value;

            % eval(sprintf('mustBeEntityType(%s, "%s")', obj.Name, char(obj.EntityType)));
            %obj.Validation = fcn;
            obj.Default = obj.EntityType(1).empty();
        end
    end
end 