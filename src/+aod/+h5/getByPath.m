function e = getByPath(entity, hdfPath)
% Return any entity within the persistent hierarchy
%
% Syntax:
%   e = aod.h5.getByPath(obj, hdfPath)
%
% Notes:
%   Returns empty with a warning if hdfPath not found
% ------------------------------------------------------------

    arguments
        entity 
        hdfPath         string 
    end
    
    if ~isSubclass(entity, 'aod.persistent.Entity')
        error('getByPath:InvalidInput',...
            'Input must be an entity from persistent interface');
    end
    
    if ~isscalar(hdfPath)
        e = aod.util.arrayfun(@(x) aod.h5.getByPath(entity, x), hdfPath);
        return
    end

    try
        e = entity.factory.create(hdfPath);
    catch ME
        if strcmp(ME.identifier, 'create:InvalidPath')
            warning('getByPath:InvalidHdfPath', ...
                'HDF path not found: %s', hdfPath);
            e = [];
        else
            rethrow(ME);
        end
    end
