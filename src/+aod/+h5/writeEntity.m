function writeEntity(hdfName, obj)
% Writes an AOData entity to an HDF5 file
%
% Description:
%   Pipeline for writing AOData entities to an HDF5 file
%
% Syntax:
%   aod.h5.writeEntity(hdfName, entity)
%
% See also:
%   aod.h5.writeExperimentToFile, aod.h5.write

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    arguments
        hdfName             {mustBeHdfFile(hdfName)}
        obj                 {mustBeA(obj, 'aod.core.Entity')}
    end

    import aod.core.EntityTypes

    entityType = EntityTypes.get(obj);
    mc = metaclass(obj);

    if entityType == EntityTypes.EXPERIMENT
        h5tools.createGroup(hdfName, '/', 'Experiment');
        h5tools.writeatt(hdfName, '/Experiment', 'Class', class(obj));
    end

    % Determine which properties will be persisted
    persistedProps = aod.h5.getPersistedProperties(obj);
    % Extract out independently set properties
    specialProps = aod.h5.getSystemProperties();
    persistedProps = setdiff(persistedProps, specialProps);
    % Extract out container properties
    containers = entityType.childContainers();
    if ~isempty(containers)
        persistedProps = setdiff(persistedProps, containers);
    end

    % Collect UUIDs of entities within the HDF5 file to locate "Parent"
    if entityType ~= EntityTypes.EXPERIMENT
        EM = aod.h5.EntityManager(hdfName);
        EM.collect();
        parentPath = entityType.parentPath(obj, EM);
        hdfPath = entityType.getPath(obj, EM, parentPath);
    else
        parentPath = '/';
        hdfPath = '/Experiment';
    end
    % Unlike parentPath, basePath includes the container 
    [basePath, groupName] = h5tools.util.splitPath(hdfPath);

    fprintf('Writing %s\n', hdfPath);

    % Create the new group
    if entityType ~= EntityTypes.EXPERIMENT
        h5tools.createGroup(hdfName, basePath, groupName);
    end

    % Create default subgroups, if necessary
    if ~isempty(containers)
        h5tools.createGroup(hdfName, hdfPath, containers{:});
        for i = 1:numel(containers)
            h5tools.writeatt(hdfName, [hdfPath, '/', containers{i}],... 
                'Class', 'Container');
        end
    end

    % Write entity identifiers
    h5tools.writeatt(hdfName, hdfPath,...
        'UUID', obj.UUID, 'Class', class(obj),... 
        'EntityType', char(entityType),...
        'LastModified', obj.LastModified,...
        'DateCreated', obj.DateCreated);

    % Write parent link, if necessary
    if ~isequal(parentPath, '/')
        try
            h5tools.writelink(hdfName, hdfPath, 'Parent', parentPath);
        catch ME
            if contains(ME.message, 'name already exists')
                warning('writeEntity:LinkExists',...
                    'Parent link from %s to %s exists', hdfPath, parentPath);
            end
        end
    end

    % Handle timing
    if isprop(obj, 'Timing') 
        if ~isempty(obj.Timing)
            aod.h5.write(hdfName, hdfPath, 'Timing', obj.Timing);
        else  % If Timing is empty, check for Parent timing to inherit
            if isprop(obj.Parent, 'Timing') && ~isempty(obj.Parent.Timing)
                h5tools.writelink(hdfName, EM.uuid2path(obj.Timing.UUID), hdfPath, 'Timing');
            end
        end
    end 

    % Write names, if exist
    h5tools.writeatt(hdfName, hdfPath, 'label', obj.label);
    if ~isempty(obj.Name)
        aod.h5.write(hdfName, hdfPath, 'Name', obj.Name);
    end

    % Write description, if exists
    if ~isempty(obj.description)
        aod.h5.write(hdfName, hdfPath, 'description', obj.description);
    end

    % Write note(s), if necessary
    if ~isempty(obj.notes)
       aod.h5.write(hdfName, hdfPath, 'notes', obj.notes);
    end

    % Write parameters, if necessary
    if ~isempty(obj.parameters)
        h5tools.writeatt(hdfName, hdfPath, obj.parameters);
    end
    
    % Write file paths, if necessary
    if ~isempty(obj.files)
        h5tools.datasets.makeStringDataset(hdfName, hdfPath, 'files', "aod.util.Parameters");
        h5tools.writeatt(hdfName, [hdfPath, '/files'], obj.files);
    end

    % Handle git repository links
    if isprop(obj, 'Code') && ~isempty(obj.Code)
        h5tools.write(hdfName, hdfPath, 'Code', obj.Code);
    end
    
    % Write remaining properties as datasets
    for i = 1:numel(persistedProps)
        try
            prop = obj.(persistedProps(i));
        catch ME
            if strcmp(ME.identifier, 'MATLAB:class:GetProhibited')
                warning('writeEntityToFile:NoGetAccess',...
                    'Property %s could not be written, get access was not public', persistedProps(i));
                prop = [];
            else
                rethrow(ME);
            end
        end
        if isempty(prop)
            continue
        end
        % Write links to other entities
        if isSubclass(prop, 'aod.core.Entity')
            parentPath = getParentPath(EM.Table, prop.UUID);
            h5tools.writelink(hdfName, hdfPath, persistedProps(i), parentPath);
            continue
        end

        % Write dataset description, if exists
        dsetDescription = aod.util.getClassPropDescription(mc, persistedProps(i));
        % Write dataset
        success = aod.h5.write(hdfName, hdfPath, persistedProps(i), prop, dsetDescription);
        if ~success
            error('Unrecognized property %s of type %s', persistedProps(i), class(prop));
        end

    end
end

function parentPath = getParentPath(EMT, parentUUID)
    isEntityInFile(EMT, parentUUID);
    parentPath = char(EMT{EMT.UUID == parentUUID, 'Path'});
end

function tf = isEntityInFile(EMT, UUID)
    if isempty(find(EMT.UUID == UUID)) %#ok<EFIND> 
        if nargout == 0
            error('Entity does not exist in HDF5 file!');
        else
            tf = false;
        end
    else
        tf = true;
    end
end
