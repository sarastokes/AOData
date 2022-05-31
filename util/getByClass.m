function value = getByClass(x, className)
    % FINDBYCLASS
    %
    % Syntax:
    %   idx = findByClass(x, className)
    %
    % History:
    %   30May2022 - SSP
    % ---------------------------------------------------------------------
    idx = cellfun(@(x) isa(x, className), x);

    if ~isempty(idx)
        value = x{idx};
    else
        value = [];
    end
