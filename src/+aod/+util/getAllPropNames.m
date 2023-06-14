function propNames = getAllPropNames(obj)
% Get all property names of an object
%
% Description:
%   propNames = getAllPropNames(obj)
%
% Inputs:
%   obj             object, class name or meta.class
%       The object with properties
%
% Outputs:
%   propNames       string array (:,1)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if istext(obj)
        mc = meta.class.fromName(obj);
    elseif isa(obj, 'meta.class')
        mc = obj;
    elseif isobject(obj)
        mc = metaclass(obj);
    end

    propNames = arrayfun(@(x) string(x.Name), mc.PropertyList);

