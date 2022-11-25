function uuid = validateUUID(uuid)
    % VALIDATEUUID
    %
    % Description:
    %   Validates the composition of a UUID
    %
    % Syntax:
    %   uuid = validateUUID(uuid)
    %
    % See also:
    %   aod.util.generateUUID
    %
    % History:
    %   24Nov2022 - SSP
    % ---------------------------------------------------------------------
    arguments
        uuid        string
    end
    
    if strlength(uuid) ~= 36 || numel(strfind(uuid, '-')) ~= 4
        error('validateUUID:InvalidInput',...
            'UUID is not properly formatted, use aod.util.generateUUID()');
    end