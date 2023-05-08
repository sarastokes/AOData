function h = uilayoutfill(parentHandle, padding)
%
% Description:
%   Create a 1x1 uigridlayout to force a single component to fill box
%
% Syntax:
%   h = aod.app.util.uilayoutfill(parentHandle)
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        padding = 5;
    end

    h = uigridlayout(parentHandle, [1 1],...
        "Padding", repmat(padding, [1 4]),...
        "Tag", "LayoutFill");