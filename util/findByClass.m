function idx = findByClass(x, className)
    % FINDBYCLASS
    %
    % Syntax:
    %   idx = findByClass(x, className)
    %
    % History:
    %   30May2022 - SSP
    % ---------------------------------------------------------------------

    if ~ischar(className)
        className = class(className);
    end
    
    if iscell(x)
        idx = cellfun(@(x) isa(x, className), x);
    else
        idx = arrayfun(@(x) isa(x, className), x);
    end