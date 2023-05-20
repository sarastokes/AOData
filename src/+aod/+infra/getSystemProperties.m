function specialProps = getSystemProperties()
% Return properties reserved by AOData
%
% Description:
%   Returns a list of persisted properties that are handled explicitly
%   when writing an entity to an HDF5 file
%
% Syntax:
%   specialProps = aod.infa.getSystemProperties

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    
    specialProps = ["Parent", "notes", "Name", "files",...
        "UUID", "description", "attributes", "Timing", "Code",...
        "expectedDatasets", "expectedAttributes"];