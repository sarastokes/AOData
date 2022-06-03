function value = getByClass(x, className)
    % FINDBYCLASS
    %
    % Syntax:
    %   idx = findByClass(x, className)
    %
    % See also:
    %   findByClass
    %
    % History:
    %   30May2022 - SSP
    %   03Jun2022 - SSP - Added call to findByClass
    % ---------------------------------------------------------------------
    idx = findByClass(x, className);
    idx = find(idx);

    if ~isempty(idx)
        if iscell(x)
            value = x{idx};
        else
            value = x(idx);
        end
    else
        value = [];
    end
