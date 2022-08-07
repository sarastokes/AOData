function tf = isUUID(value)
    % ISUUID
    %
    % Description:
    %   Determines if input is a UUID (36 characters long w/ 4 hyphens)
    %
    % Syntax:
    %   tf = isUUID(value)
    %
    % History:
    %   03Aug2022 - SSP
    % ---------------------------------------------------------------------

    if isstring(value)
        value = char(value);
    end

    tf = numel(value) == 36 && numel(strfind(value, '-')) == 4;
