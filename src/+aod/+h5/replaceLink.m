function replaceLink(entity, linkName, newTarget)
% Replaces existing softlink
%
% Description:
%   Changes the target for an existing softlink, preserving attributes
%
% Syntax:
%   aod.h5.replaceLink(entity, linkName, newTarget)
%
% Inputs:
%   entity              aod.persistent.Entity subclass
%       Entity containing the softlink
%   linkName            char
%       Name of the softlink
%   newTarget           char or aod.persistent.Entity subclass
%       The hdf path or entity that will be the new softlink destination 
%       
%
% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        entity      {mustBeA(entity, 'aod.persistent.Entity')}
        linkName    char
        newTarget 
    end

    if isSubclass(newTarget, 'aod.persistent.Entity')
        if isequal(newTarget, entity)
            error('fixLink:CircularPath',...
                'Target entity is the same as source entity');
        end
        newPath = newTarget.hdfPath;
    elseif istext(newTarget)
        if ~h5tools.exist(entity.hdfName, newTarget)
            error('fixLink:PathDoesNotExist', ...
                'Path %s not found in %s', newPath, entity.hdfName);
        end
        newPath = newTarget;
    end

    linkPath = h5tools.buildPath(entity.hdfPath, linkName);

    % Store the attributes then delete the link
    %linkAttr = h5tools.readatt(entity.hdfName, linkPath, 'all');
    h5tools.deleteObject(entity.hdfName, linkPath);
    % Recreate the link and attributes
    h5tools.writelink(entity.hdfName, ...
        entity.hdfPath, obj.Name, newPath);
    %h5tools.writeatt(entity.hdfName, newPath, linkAttr);
