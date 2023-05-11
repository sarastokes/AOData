function app = AOQueryApp(experiment)
% Opens AOQueryApp
%
% Syntax:
%   AOQueryApp()
%   AOQueryApp(experiment)
%
% Optional inputs:
%   experiment      HDF5 file name(s) or aod.persistent.Experiment
%       AOData experiments to query (default = picked in UI)
%
% Examples:
%   % Open and choose file(s) from the UI
%   AOQueryApp()
%   % Open and load in a file
%   AOQueryApp("test/ToyExperiment.h5")
%
% See also:
%   aod.app.query.QueryView


% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 1
        experiment = [];
    end

    queryView = aod.app.query.QueryView(experiment);

    if nargout > 0
        app = queryView;
    end