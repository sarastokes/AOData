function out = getClassPropDescription(mc, propName)
% Returns the description of a class's property (if it exists)
%
% Description:
%   Returns the description of a property, the comment above the 
%   property's definition in the property block of a classdef file.
%
% Syntax:
%   out = getClassPropDescription(mc, propName)
%
% Inputs:
%   mc              instance of class or meta.class
%       Instance of the class containing property or meta.class (for speed)
%   propName        property name
%       The property to search for the description
%
% See also:
%   metaclass

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if ~isa(mc, 'meta.class')
        mc = metaclass(mc);
    end
    idx = find(arrayfun(@(x) strcmp(x.Name, propName), mc.PropertyList));
    if isempty(idx)
        error("getClassPropDescription:PropertyNotFound",...
            "Property %s not found", propName);
    end
    out = mc.PropertyList(idx).Description;