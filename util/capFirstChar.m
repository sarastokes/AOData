function txt = capFirstChar(txt)
% Capitalizes the first character of a char or string
%
% Syntax:
%   txt = capFirstChar(txt)
%
% Input:
%   txt         char, cellstr, string 
%
% Output:
%   txt         char, cellstr, string 
%       Class of output depends on class of input.
%
% See also:
%   camelCase

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    assert(istext(txt), 'Input must be char or string');

    if ~isscalar(txt)
        out = aod.util.arrayfun(@(x) capFirstChar(x), txt);
        return
    end

    isString = isstring(txt);
    if isString
        txt = char(txt);
    end

    txt(1) = upper(txt(1));

    if isString
        txt = string(txt);
    end