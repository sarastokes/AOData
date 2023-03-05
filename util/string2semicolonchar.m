function out = string2semicolonchar(txt)
% Extract values separated by semicolors from a string, return as char
%
% Description:
%   Converts a string array to a char with each string separated by
%   a semicolon. Needed for setpref() which doesn't do string arrays
%
% Syntax:
%   out = string2semicolonchar(txt)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    assert(isstring(txt), 'Input must be string');
    
    out = char(txt(1));
    if numel(txt) == 1
        return
    end
    for i = 2:numel(txt)
        out = [out, ';', char(txt(i))]; %#ok<AGROW> 
    end
    