function value = getGridSize(gridHandle, dim)
% Get the number of filled rows or columns
%
% Syntax:
%   h = getGridSize(gridHandle, dim)
%

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    switch dim
        case 1
            value = arrayfun(@(x) x.Layout.Row, gridHandle.filterGrid.Children);
        case 2
            value = arrayfun(@(x) x.Layout.Column, gridHandle.filterGrid);
    end

    if isempty(value)
        value = 0;
    else
        value = max(value);
    end