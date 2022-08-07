function tf = isSubclass(x, className)
    % ISSUBCLASS
    %
    % Syntax:
    %   tf = isSubclass(x, className)
    %
    % History:
    %   03Jun2022 - SSP
    %   05Aug2022 - SSP - Added check for class membership
    % ---------------------------------------------------------------------

    if isa(x, className)
        tf = true;
        return
    end
    tf = ismember(className, superclasses(x));

