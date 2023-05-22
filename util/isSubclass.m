function tf = isSubclass(x, className)
% Determine whether input is a subclass of one or more class names
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
        tf = ismember(x, superclasses(x));
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