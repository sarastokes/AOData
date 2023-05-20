function tf = istext(obj, cellstrFlag)
% Type-agnostic text detector
%
% Description:
%   Returns true if input is of type string, char or, optionally, cellstr
%
% Syntax:
%   tf = istext(obj, cellstrFlag)
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        cellstrFlag = false;
    end

    if cellstrFlag
        tf = ischar(obj) | isstring(obj) | iscellstr(obj);
    else
        tf = ischar(obj) | isstring(obj);
    end