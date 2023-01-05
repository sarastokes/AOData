function e = loadExperiment(hdfName, entityFactory)
% Load an AOData HDF5  file
%
% Description:
%   Load an experiment from an HDF5 file to persistent interface
%
% Syntax:
%   e = loadExperiment(hdfName)
%   e = loadExperiment(hdfName, entityFactory)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    % We need the full HDF5 file path
    hdfName = getFullFile(hdfName);

    if nargin < 2 || isempty(entityFactory)
        EF = aod.persistent.EntityFactory(hdfName);
    else
        EF = entityFactory;
    end
    
    e = EF.getExperiment();




