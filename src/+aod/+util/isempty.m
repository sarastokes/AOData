function tf = isempty(input)
% Test whether input is empty OR empty string ("")
%
% Syntax:
%   tf = aod.util.isempty(input)
%
% See also:
%   isempty

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if isempty(input)
        tf = true;
    elseif isstring(input) && all(input(:) == "")
        tf = true;
    else
        tf = false;
    end