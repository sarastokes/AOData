function tf = isSubclass(x, className)
    % ISSUBCLASS
    %
    % Syntax:
    %   tf = isSubclass(x, className)
    %
    % Inputs:
    %   x               object
    %   className       string, char or cellstr
    %
    % Examples:
    %   tf = isSubclass(obj, 'double')
    %   tf = isSubclass(obj, ["double", "char"])
    %   tf = isSubclass(obj, {'double', 'char'})
    %
    % History:
    %   03Jun2022 - SSP
    %   05Aug2022 - SSP - Added check for class membership
    %   03Sep2022 - SSP - Added support for multiple class names
    % ---------------------------------------------------------------------
    arguments
        x
        className           string
    end

    for i = 1:numel(className)
        if isa(x, className(i))
            tf = true;
            return
        end
        if ismember(className(i), superclasses(x))
            tf = true;
            return
        end
    end
    tf = false;