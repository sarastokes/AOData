function expt = loadExperiment(hdfName, entityFactory)
% Load an AOData HDF5 file
%
% Description:
%   Load an experiment from an HDF5 file to persistent interface
%
% Syntax:
%   expt = loadExperiment(hdfName)
%   expt = loadExperiment(hdfName, entityFactory)
%
% Inputs:
%   hdfName         char or string
%       The AOData HDF5 file name
% Optional inputs:
%   entityFactory   aod.persistent.EntityFactory 
%       The factory for creating entities (default = AOData standard)
%
% Outputs:
%   expt            aod.persistent.Experiment
%
% See also:
%   aod.persistent.EntityFactory, aod.persistent.Experiment

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    
    % We need the full HDF5 file path
    hdfName = getFullFile(hdfName);

    if nargin < 2 || isempty(entityFactory)
        expt = aod.persistent.EntityFactory.init(hdfName);
    else
        expt = entityFactory.getExperiment();
    end
