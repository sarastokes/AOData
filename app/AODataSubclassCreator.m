function [model, app] = AODataSubclassCreator(model)
% Open the application for generating template subclasses
%
% Syntax:
%   [model, app] = AODataSubclassCreator(model)
%
% See also:
%   aod.app.creator.SubclassGenerator, aod.app.creator.SubclassWriter, 
%   aod.app.creator.SubclassGeneratorController
%

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if nargin < 1
        model = aod.app.creator.SubclassGenerator();
    end

    app = aod.app.creator.SubclassGeneratorController(model);
