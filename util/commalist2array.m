function out = commalist2array(input)
% Convert a comma-separated list to a string array
%
% Syntax:
%   out = commalist2array(input)
%
% See also:
%   array2commalist

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------


    txt = convertStringsToChars(input);
    txt = strsplit(txt, ',');

    out = string.empty();
    for i = 1:numel(txt)
        if isempty(txt)
            continue
        end
        out = cat(1, out, string(strtrim(txt{i})));
    end