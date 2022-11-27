function out = semicolonchar2string(txt)
    % SEMICOLONCHAR2STR
    %
    % Description:
    %   Converts a char with text separated by a semicolons into a string
    %   array. Needed for setpref() which doesn't do string arrays
    %
    % Syntax:
    %   out = semicolonchar2string(txt)
    % 
    % History:
    %   26Nov2022 - SSP
    % ---------------------------------------------------------------------

    assert(ischar(txt), 'Input must be char');
    if isempty(strfind(txt, ';'))
        out = string(txt);
    else
        out = string(strsplit(txt, ';'));
    end
