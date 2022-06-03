function tf = isSubclass(x, className)
    % ISSUBCLASS
    %
    % Syntax:
    %   tf = isSubclass(x, className)
    %
    % History:
    %   03Jun2022 - SSP
    % ---------------------------------------------------------------------

    tf = ismember(className, superclasses(x));

