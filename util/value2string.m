function out = value2string(input)
% Convert a value to a string representation
%
% Description:
%   Convert to a string representation that can return original value 
%   from the eval() function
%
% Syntax:
%   out = value2string(input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    if isempty(input)
        out = "[]";
        return 
    end

    out = strtrim(formattedDisplayText(input));
    if ischar(input)
        out = "'" + out + "'";
    elseif isstring(input)
        out = string(sprintf('"%s"', out));
    elseif isnumeric(input) && numel(input) > 1
        out = "[" + out + "]";
    end
    