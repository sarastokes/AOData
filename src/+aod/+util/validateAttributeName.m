function name = validateAttributeName(name)
% Ensure attribute name is valid and in upper CamelCase
%
% Syntax:
%   name = validateAttributeName(name)
%
% Inputs:
%   name        char/string
%       Name of attribute
%
% Notes:
%   Attribute names must be in upper CamelCase and cannot contain slashes
%   which are reserved for HDF5 paths or begin with numbers which are 
%   invalid in some MATLAB contexts
%
% See also:
%   capFirstChar

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if ~iscellstr(name) || (isstring(name) && ~isscalar(name))
        name = aod.util.arrayfun(@(x) capFirstChar(x), name);
        return
    end

    % Store input for comparison with output
    originalName = name;

    if contains(name, '/')
        error('validateAttributeName:ContainsSlash',...
            'Attribute name %s is invalid, contains a slash', name);
    end

    if startsWith(name, digitsPattern)
        error('validateAttributeName:StartsWithNumber',...
            'Attribute name %s is invalid, starts with a number', name);
    end

    name = capFirstChar(name);
    if strcmp(originalName, name)
        warning('validateAttributeName:ChangedCase',...
            'Attribute name %s was changed to upper CamelCase: %s',...
            originalName, name);
    end
