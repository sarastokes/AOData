function S = collectAllSchemas(currentFlag)
% COLLECTALLSCHEMAS
%
% Description:
%   Collect all schemas into a single struct
%
% Syntax:
%   S = aod.schema.util.collectAllSchemas()
%
% Notes:
%   Speed = 0.06 seconds per schema
%
% See also:
%   aod.schema.util.collectRegistries, nestStruct, mergeNestedStructs

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    T = aod.schema.util.collectRegistries();

    S = struct();
    for i = 1:height(T)
        schema = aod.schema.util.StandaloneSchema(T.Name(i));
        newStruct = schema.struct();
        newStruct = nestStruct(newStruct, strsplit(T.Name(i), "."));
        S = mergeNestedStructs(S, newStruct);
    end
end

function S = getLoggedSchemas(T)
    S = struct();
    for i = 1:height(T)
        fPath = [];
    end
end