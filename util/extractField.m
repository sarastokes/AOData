function [S, fieldValue] = extractField(S, fieldName)
% EXTRACTFIELD
%
% Description:
%   Remove a field from a struct and return its value
%
% Syntax:
%   [S, fieldValue] = extractField(S, fieldName);
%
% History:
%   24Aug2022 - SSP
% -------------------------------------------------------------------------

    assert(isstruct(S), 'extractField: First input must be struct');
    assert(istext(fieldName), 'extractField: Second input must be text');

    try
        fieldValue = S.(fieldName);
        S = rmfield(S, fieldName);
    catch ME 
        if strcmp(ME.identifier, 'MATLAB:nonExistentField')
            error("extractField:nonExistentField",...
                "Structure did not contain field named %s", fieldName);
        else
            rethrow(ME);
        end
    end
