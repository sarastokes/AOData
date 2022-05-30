function dispMapContents(mapObj)
    % DISPMAPCONTENTS
    %
    % Description:
    %   Display contents of a containers.Map object
    %
    % Syntax:
    %   dispMapContents(mapObj)
    %
    % History:
    %   30May2022 - SSP
    % ---------------------------------------------------------------------

    if isempty(mapObj)
        fprintf('Map object is empty\n');
        return
    end

    k = mapObj.keys;
    for i = 1:numel(k)
        fprintf('%s = ', k{i});
        disp(mapObj(k{i}));
    end