function value = char2logical(txt)
    % CHAR2LOGICAL
    %
    % Description:
    %   Convert 'true' or 'false' to logical
    %
    % Syntax:
    %   value = char2logical(txt)
    %
    % History:
    %   08Jun2022 - SSP
    % ---------------------------------------------------------------------

    switch lower(txt)
        case 'true'
            value = true;
        case 'false'
            value = false;
        otherwise
            error('CHAR2LOGICAL: Input must be true or false, was %s', txt);
    end