function out = array2commalist(input)
% Convert string array to list separated by commas
%
% Syntax:
%   out = array2commalist(input)
%
% See also:
%   commalist2array

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    arguments
        input       string
    end
    
    if numel(input) == 1
        out = input;
        return
    end

    out = "";
    for i = 1:numel(input)
        if i > 1
            out = out + ", ";
        end
        out = out + input(i);
    end