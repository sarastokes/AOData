function isMissing = getMissing(input)
% Return missing values in array or cell
%
% Syntax:
%   isMissing = getMissing(input)
%
% See also:
%   extractCellData, standardizeMissing
    
% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if iscell(input)
        isMissing = cellfun(@(x) all(ismissing(x)), input);
    else
        isMissing = ismissing(input);
    end