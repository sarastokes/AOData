function AM = getAttributeSpecification(aoClass, verbose)
% Returns expectedAttributes from AOData class or class name
%
% Syntax:
%   p = aod.specification.util.getAttributeSpecification(aoClass, verbose)
%
% Inputs:
%   aoClass         string
%       Class name (must be subclass of aod.core.Entity)
% Optional inputs:
%   verbose         logical (default = false)
%       Whether to print a table of the specification to the cmd line
%
% Outputs:
%   AM              aod.specification.AttributeManager
%
% See also:
%   aod.specification.util.getDatasetSpecification, 
%   aod.specification.AttributeManager

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        verbose = false;
    end
    
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
        AM = [];
        return
    end

    eval(sprintf('AM = %s.specifyAttributes();', aoClass));
    AM.setClassName(aoClass);

    if verbose 
        disp(p.table());
    end