function out = getCharIdx(str, idx)
% Use char-like indexing to get substring
%
% Syntax:
%   out = getCharIdx(str, idx)
%
% Inputs:
%   str             scalar string
%   idx             integer indices
%       Indices of characters within string to return
%
% Examples:
%   getCharIdx("test", 1)
%   > "t"
%   getCharIdx("test", 2:3)
%   > "es"

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    arguments
        str         string      
        idx         double      {mustBeInteger}
    end

    assert(isscalar(str), 'String input must be scalar');

    str = char(str);
    out = string(str(idx));