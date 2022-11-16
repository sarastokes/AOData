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

    % We need the full HDF5 file path
    [hdfPath, hdfName, ext] = fileparts(hdfName);
    W = what(hdfPath);
    fullHdfFile = fullfile(W.path, [hdfName, ext]);

    if nargin < 2 || isempty(entityFactory)
        EF = aod.persistent.EntityFactory(fullHdfFile);
    else
        EF = entityFactory;
    end
    
    e = EF.getExperiment();




