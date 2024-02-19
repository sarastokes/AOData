function S = getNestedField(S, fieldName)
% GETNESTEDFIELD
%
% Description:
%   Get a nested field within a struct by providing the fieldname(s)
%
% Syntax:
%   S = getNestedField(S, fieldName)
%
% Examples:
%   S = getNestedField(S, "field1.field2")
%   S = getNestedField(S, ["field1", "field2"])
%
% See also:
%   struct, mergeNestedStructs, nestStruct

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------
    arguments
        S       (1,1)       struct
        fieldName           string
    end

    if contains(fieldName, ".")
        if isscalar(fieldName)
            fieldName = strsplit(fieldName, ".");
        else
            error("getNestedField:InvalidInput",...
                "If input name contains '.', it must be scalar");
        end
    end

    for i = 1:numel(fieldName)
        S = S.(fieldName(i));
    end
end