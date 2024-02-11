function tf = isInputEmpty(input)
% ISINPUTEMPTY
%
% Description:
%   Checks if input is empty or "[]"
%
% Syntax:
%   tf = aod.schema.util.isInputEmpty(input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    input = convertCharsToStrings(input);
    if aod.util.isempty(input) || isequal(input, "[]")
        tf = true;
    elseif isstring(input) && all(isequal(input, "[]"))
        tf = true;
    else
        tf = false;
    end
