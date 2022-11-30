function S  = map2struct(map)
    % MAP2STRUCT
    %
    % Description:
    %   Convert a containers.Map to a struct
    %
    % Syntax:
    %   S = map2struct(map)
    %
    % Inputs:
    %   map             containers.Map (keyvalue = char/string)
    %
    % History:
    %   03Jun2022 - SSP
    % ---------------------------------------------------------------------

    S = struct();
    if isempty(map)
        return
    end

    keys = map.keys;
    values = map.values;

    for i = 1:numel(keys)
        S.(keys{i}) = values{i};
    end