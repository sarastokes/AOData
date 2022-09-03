function e = loadExperiment(hdfName, entityFactory)
    % LOADEXPERIMENT
    %
    % Description:
    %   Load an experiment from an HDF5 file
    %
    % Syntax:
    %   e = loadExperiment(hdfName)
    %   e = loadExperiment(hdfName, entityFactory)
    % --------------------------------------------------------------------

    if nargin < 2
        EF = aod.core.persistent.EntityFactory(hdfName);
    else
        EF = entityFactory;
    end
    
    e = EF.getExperiment();




