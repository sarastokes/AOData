classdef (ConstructOnLoad) ValidationEvent < event.EventData
% Validation failure event
%
% Superclasses:
%   event.EventData
%
% Constructor:
%   obj = aod.specification.events.ValidationEvent(specType, msg)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        PropName    (1,1)       string
        SpecType    (1,1)       string
        Message     (1,1)       string
    end

    methods
        function obj = ValidationEvent(specType, details)
            arguments 
                specType    (1,1)   string 
                details     (1,1)           = string.empty()
            end 

            obj.PropName = "TBD";
            obj.SpecType = specType;
            if ~isempty(details) && isa(details, "MException")
                details = sprintf("%s -- %s", details.identifier, details.message);
            end
            obj.Message = details;
        end

        function assignPropName(obj, value)
            obj.PropName = value;
        end
    end
end