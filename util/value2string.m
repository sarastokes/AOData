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
        out = sprintf("%s.%s", class(input), out);
    elseif isnumeric(input) 
        if numel(input) == 1
            out = num2str(out);
        else
            out = "[" + out + "]";
            % Replace newline with semicolon
            out = strrep(out, newline, ";");
            % Remove repeated spaces
            idx = strfind(out, " ");
            repeatedSpaces = diff(idx);
            if any(repeatedSpaces == 1)
                idx = idx(1+find(repeatedSpaces==1));
                out = char(out);
                out(idx) = [];
                out = string(out);
            end
        end
        % Add class if not double
        if ~isa(input, 'double')
            out = sprintf("%s(%s)", class(input), out);
        end 
    end
    