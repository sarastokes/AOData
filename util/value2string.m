function out = value2string(input)
% Convert a value to a string representation
%
% Description:
%   Convert to a string representation that can return original value 
%   from the eval() function
%
% Syntax:
%   out = value2string(input)
%
% Notes:
%   Supports string, char, enum and all numeric types

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
    elseif isenum(input)
        mc = metaclass(input);
        out = sprintf("%s.%s")
    elseif isnumeric(input) 
        if numel(input) > 1
            out = "[" + out + "]";
        end
        if ~isa(input, 'double')
            out = sprintf("%s(%s)", class(input), out);
        end 
    end
    