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
%   aod.app.manager.PackageManagerView,
%   aod.app.manager.PackageManagerPresenter

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    p = aod.app.manager.PackageManagerPresenter();
    p.show();

    if nargout > 0
        app = p;
    end
