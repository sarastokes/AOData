function DM = getDatasetSpecification(className)
% Get the data specification for a specific class
%
% Syntax:
%   DM = aod.specification.util.getDatasetSpecification(className)
%
% Inputs:
%   className       meta.class, text or object
%
% Outputs:
%   DM              aod.specification.DatasetManager.populate(mc)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if isa(className, 'meta.class')
        mc = className;
    elseif istext(className)
        mc = meta.class.fromName(className);
    else
        mc = metaclass(className);
    end

    if ~isSubclass(mc, 'aod.core.Entity')
        error('getDatasetSpecification:InvalidClass',...
            'Only subclasses of aod.core.Entity have specifications');
    end

    expectedDatasets = aod.specification.DatasetManager.populate(mc);
    fcn = str2func(sprintf("@(x) %s.specifyDatasets(x)", mc.Name));
    DM = fcn(expectedDatasets);
