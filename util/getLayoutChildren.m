function h = getLayoutChildren(parent, rowID, colID)
    % GETLAYOUTCHILDREN
    %
    % Description:
    %   Return layout children in specific rows or columns
    % 
    % Syntax:
    %   h = getLayoutChildren(parent, rowID, colID)
    %
    % Note:
    %   If either colID or rowID is left empty, all will be returned
    %
    % History:
    %   30Oct2022 - SSP
    % ---------------------------------------------------------------------
    arguments
        parent {mustBeA(parent, 'matlab.ui.container.GridLayout')}
        rowID       = []
        colID       = []
    end

    h = [];
    children = parent.Children;

    if isempty(children)
        return
    end

    if isempty(rowID) && isempty(colID)
        h = children;
        return;
    end

    for i = 1:numel(children)
        rowFlag = isempty(rowID) | ismember(children(i).Layout.Row, rowID);
        colFlag = isempty(colID) | ismember(children(i).Layout.Column, colID);
        if rowFlag && colFlag
            h = cat(1, h, children(i));
        end            
    end
end