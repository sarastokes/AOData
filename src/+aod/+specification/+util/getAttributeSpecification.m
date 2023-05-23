function p = getAttributeSpecification(aoClass, verbose)
% Returns expectedAttributes from AOData class or class name
%
% Syntax:
%   p = aod.specification.util.getAttributeSpecification(aoClass, verbose)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        verbose = false;
    end
    
    if ~istext(aoClass)
        aoClass = class(aoClass);
    end 
    aoClass = convertCharsToStrings(aoClass);

    eval(sprintf('p = %s.specifyAttributes();', aoClass));

    if verbose 
        disp(p.table());
    end