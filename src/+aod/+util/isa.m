function tf = isa(value, classNames)
% Determine whether a value matches one or more class names
%
% Description:
%   This is a wrapper for MATLAB's isa function that accepts one or more 
%   class names. The builtin isa accepts only one class name
%
% Syntax:
%   tf = isa(value, classNames)
%
% Examples:
%   tf = aod.util.isa(123, ["double", "string"])
%   >>> Returns 'true'
%
% See also:
%   isa, arrayfun, mustBeA

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments 
        value 
        classNames      string 
    end
    
    tf = any(arrayfun(@(x) isa(value, x), classNames));