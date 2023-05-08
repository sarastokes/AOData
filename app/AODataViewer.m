function appHandle = AODataViewer(experiment)
% Open the AODataViewer app
%
% Syntax:
%   AODataViewer(persistedExperiment)
%   appHandle = AODataViewer(persistedExperiment)
%
% Inputs:
%   persistedExperiment     aod.persistent.Experiment or HDF5 file name
%
% Optional outputs:
%   appHandle               aod.app.viewer.ExperimentPresenter
%       The object controlling AODataViewer, useful for dev or debugging
%
% See also:
%   aod.app.viewer.ExperimentPresenter, aod.app.viewer.ExperimentView


% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    
    if nargin < 1
        % Let ExperimentPresenter run uigetfile
        experiment = [];
    end
    
    p = aod.app.viewers.ExperimentPresenter(experiment);
    p.show();
    if nargout > 0
        appHandle = p;
    end