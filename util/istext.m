function tf = istext(obj)
% ISTEXT
%
% Description:
%   Returns true if input is of type string, char or cellstr
%
% Syntax:
%   tf = istext(obj)
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    
    tf = ischar(obj) | isstring(obj) | iscellstr(obj);
