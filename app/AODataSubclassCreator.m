function [model, app] = AODataSubclassCreator(model)
% Open the application for generating template subclasses
%
% Syntax:
%   [model, app] = AODataSubclassCreator(model)
%
% See also:
%   aod.app.creator.CustomSubclass, aod.app.creator.SubclassWriter, 
%   aod.app.creator.CustomSubclassController
%

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if nargin < 1
        model = aod.app.creator.CustomSubclass();
    end

    app = aod.app.creator.CustomSubclassController(model);
