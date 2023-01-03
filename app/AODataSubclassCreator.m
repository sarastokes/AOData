function [model, app] = AODataSubclassCreator(model)
% Open the application for generating template subclasses
%
% Syntax:
%   [model, app] = AODataSubclassCreator(model)
%
% See also:
%   aod.app.models.SubclassGenerator, aod.app.views.SubclassWriter, 
%   aod.app.controllers.SubclassGeneratorController
%

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if nargin < 1
        model = aod.app.models.SubclassGenerator();
    end

    app = aod.app.controllers.SubclassGeneratorController(model);
