function tf = isSubclass(x, className)
% Determine whether input is a subclass of one or more class names
%
% Syntax:
%   tf = isSubclass(x, className)
%
% Inputs:
%   x               object, meta.class
%   className       string, char or cellstr
%
% Examples:
%   tf = isSubclass(obj, 'double')
%   tf = isSubclass(obj, ["double", "char"])
%   tf = isSubclass(obj, {'double', 'char'})
%
% See also:
%   isa, superclasses, class

% History:
%   03Jun2022 - SSP
%   05Aug2022 - SSP - Added check for class membership
%   03Sep2022 - SSP - Added support for multiple class names

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        x
        className           string
    end

    % Parse class name
    if istext(x) && exist(x, 'class')
        tf = strcmpi(x, className) | ismember(className, superclasses(x));
        return
    end

    if isa(x, 'meta.class')
        if strcmp(x.Name, className)
            tf = true;
        else
            tf = ismember(className, superclasses(x.Name));
        end
        return
    end

    % Parse class object
    for i = 1:numel(className)
        if isa(x, className(i))
            tf = true;
            return
        end
        if ismember(className(i), superclasses(class(x)))
            tf = true;
            return
        end
    end
    tf = false;