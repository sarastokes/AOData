function getGridSize(gridHandle, dim)
    % GETGRIDSIZE
    %
    % Description:
    %   Get the number of filled rows or columns
    %
    % Syntax:
    %   h = getGridSize(gridHandle, dim)
    %
    % History:
    %   30Oct2022 - SSP
    % ---------------------------------------------------------------------
    switch dim
        case 1
            value = arrayfun(@(x) x.Layout.Row, v.filterGrid.Children);
        case 2
            value = arrayfun(@(x) x.Layout.Column, v.filterGrid);
    end

    if isempty(value)
        value = 0;
    else
        value = max(value)
    end