function out = string2semicolonchar(txt)
    % STRING2SEMICOLONCHAR
    %
    % Description:
    %   Converts a string array to a char with each string separated by
    %   a semicolon. Needed for setpref() which doesn't do string arrays
    %
    % Syntax:
    %   out = string2semicolonchar(txt)
    % 
    % History:
    %   26Nov2022 - SSP
    % ---------------------------------------------------------------------

    assert(isstring(txt), 'Input must be string');
    
    out = char(txt(1));
    if numel(txt) == 1
        return
    end
    for i = 2:numel(txt)
        out = [out, ';', char(txt(i))];
    end
    