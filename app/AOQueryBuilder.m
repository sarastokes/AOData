function app = AOQueryBuilder(hdfName)
% Opens AOQueryBuilder application
%
% Syntax:
%   app = AOQueryBuilder(hdfName)
%
% See Also:
%   aod.app.presenters.QueryPresenter, aod.app.views.QueryView

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if nargin == 0
        % Let QueryPresenter open uigetfile
        hdfName = [];
    end

    p = aod.app.presenters.QueryPresenter(hdfName);
    p.show();

    if nargout > 0
        app = p;
    end