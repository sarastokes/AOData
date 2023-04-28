function pEntity = swapInterfaces(cEntity)
% Swap entity from core to persisted interface
%
% Syntax:
%   pEntity = aod.util.swapInterface(cEntity);
%
% Examples:
%   pEXPT = loadExperiment('ToyExperiment.h5');
%   newAnalysis = aod.core.Analysis("AnotherAnalysis");
%   pEXPT.add(newAnalysis);
%   newAnalysis = aod.util.swapInterfaces(newAnalysis);
%
% Notes:
%   swapInterfaces for Experiment entities is not supported
%
% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        cEntity         {mustBeA(cEntity, 'aod.core.Entity')}
    end

    aod.util.mustHaveParent(cEntity);
    assert(cEntity.entityType ~= aod.core.EntityTypes.EXPERIMENT,...
        "swapInterface only works for non-experiment entities");
    
    h = cEntity.ancestor('Experiment');
    if ~isSubclass(h, 'aod.persistent.Entity')
        error("swapInterfaces:NoPersistedParent",...
        "Entity must have a persisted parent");
    end

    T = h.factory.entityManager.Table;
    path = T{T.UUID == cEntity.UUID, 'Path'};
    if isempty(path)
        error("swapInterface:EntityNotFound",...
            "Entity not found in persisted experiment");
    end
    pEntity = h.getByPath(path);


    