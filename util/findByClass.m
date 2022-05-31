function idx = findByClass(x, className)
    % FINDBYCLASS
    %
    % Syntax:
    %   idx = findByClass(x, className)
    %
    % History:
    %   30May2022 - SSP
    % ---------------------------------------------------------------------
    idx = cellfun(@(x) isa(x, className), x);
