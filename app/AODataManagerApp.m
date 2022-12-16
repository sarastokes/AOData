function p = AODataManagerApp()
% Opens user interface for managing AOData
%
% Description:
%   Opens app for viewing and editing AOData search paths and repos
%
% Syntax:
%   AODataManagerApp()
%
% See also:
%   aod.app.views.PackageManagerView,
%   aod.app.presenters.PackageManagerPresenter

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    p = aod.app.presenters.PackageManagerPresenter();
    p.show();

    if nargout > 0
        app = p;
    end
