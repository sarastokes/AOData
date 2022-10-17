function app = viewExperiment(hdfName)
    % VIEWEXPERIMENT
    %
    % Description:
    %   Open AOData HDF file in H5TreeView
    %
    % Syntax:
    %   app = viewExperiment(hdfName)
    % ---------------------------------------------------------------------

    arguments
        hdfName         {mustBeFile{hdfName}}
    end

    app = H5TreeView(hdfName)