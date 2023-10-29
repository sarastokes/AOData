function props = getSystemProperties()
% Return properties reserved by AOData
%
% Description:
%   Returns a list of persisted properties that are handled explicitly
%   when writing an entity to an HDF5 file
%
% Syntax:
%   props = aod.infa.getSystemProperties()

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    props = ["Parent", "notes", "Name", "files", "Schema",...
        "UUID", "description", "attributes", "Timing", "Code"];
    %props = [props, aod.common.EntityTypes.allContainerNames()];
