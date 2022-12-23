function uuid = validateUUID(uuid)
% Ensure UUID is valid
%
% Description:
%   Validates the composition of a UUID
%
% Syntax:
%   uuid = aod.util.validateUUID(uuid)
%
% See also:
%   aod.util.generateUUID

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    arguments
        uuid        string
    end
    
    if strlength(uuid) ~= 36 || numel(strfind(uuid, '-')) ~= 4
        error('validateUUID:InvalidInput',...
            'UUID is not properly formatted, use aod.util.generateUUID()');
    end