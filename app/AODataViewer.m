function appHandle = AODataViewer(experiment)
% Open the AODataViewer app
%
% Syntax:
%   AODataViewer(persistedExperiment)
%
% Inputs:
%   persistedExperiment     aod.persistent.Experiment or HDF5 file name
%
% See also:
%   aod.app.presenters.ExperimentPresenter, aod.app.views.ExperimentView


% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    if nargin < 1
        % Let ExperimentPresenter run uigetfile
        experiment = [];
    end
    
    p = aod.app.presenters.ExperimentPresenter(experiment);
    p.show();
    if nargout > 0
        appHandle = p;
    end