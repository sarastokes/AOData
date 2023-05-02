function specialProps = getSystemProperties()
% Return properties reserved by AOData
%
% Description:
%   Returns a list of persisted properties that are handled explicitly
%   when writing an entity to an HDF5 file
%
% Syntax:
%   specialProps = aod.h5.getSystemProperties

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    specialProps = ["Parent", "notes", "Name", "files",...
        "UUID", "description", "parameters", "Timing", "Code",...
        "expectedDatasets", "expectedParameters"];