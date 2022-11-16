function appHandle = AODataViewer(experiment)
    % AODATAVIEWER
    %
    % Syntax:
    %   AODataViewer(experiment)
    %   appHandle = AODataViewer(experiment)
    %
    %
    % See also:
    %   aod.app.presenters.ExperimentPresenter(experiment)
    %   aod.app.views.ExperimentView()
    %
    % History:
    %   15Nov2022 - SSP
    % ---------------------------------------------------------------------
    
    p = aod.app.presenters.ExperimentPresenter(experiment);
    if nargout > 0
        appHandle = p;
    end