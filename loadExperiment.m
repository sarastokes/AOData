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

    hdfName = convertStringsToChars(hdfName);
    
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




