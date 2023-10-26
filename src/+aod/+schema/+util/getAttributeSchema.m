function attrCollection = getAttributeSchema(aoClass)
% Returns expectedAttributes from AOData class or class name
%
% Syntax:
%   p = aod.schema.util.getAttributeSchema(aoClass)
%
% Inputs:
%   aoClass         string
%       Class name (must be subclass of aod.core.Entity)
%
% Outputs:
%   AM              aod.specification.AttributeManager
%
% See also:
%   aod.schema.collections.AttributeCollection, specifyAttributes

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if ~istext(aoClass)
        if isa(aoClass, "meta.class")
            aoClass = aoClass.Name;
        elseif isobject(aoClass)
            aoClass = class(aoClass);
        end
    end
    aoClass = convertCharsToStrings(aoClass);
    if ~isSubclass(aoClass, 'aod.core.Entity')
        warning('getAttributeSpecification:InvalidClass',...
            'Only subclasses of aod.core.Entity have specifications');
        attrCollection = [];
        return
    end

    eval(sprintf('attrCollection = %s.specifyAttributes();', aoClass));
    attrCollection.setClassName(aoClass); %#ok<NODEF>