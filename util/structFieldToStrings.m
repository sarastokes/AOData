function out = structFieldToStrings(S, fieldName)
    % STRUCTFIELDTOSTRINGS
    %
    % Description:
    %   Extract struct array field and concatenate into a string array
    %
    % Syntax:
    %   out = structFieldToStrings(S, fieldName)
    %
    % Inputs:
    %   S           struct
    %   fieldName   name of field within struct array
    %
    % Output 
    %   string array [N x 1]
    % ---------------------------------------------------------------------

    arguments
        S           struct 
        fieldName   char 
    end
    
    if ~isfield(S, fieldName)
        error('structFieldToStrings:InvalidFieldName',...
            'Field name %s not found', fieldName);
    end

    if isscalar(S)
        out = string(S.(fieldName));
    else
        out = string({S.(fieldName)})';
    end
    