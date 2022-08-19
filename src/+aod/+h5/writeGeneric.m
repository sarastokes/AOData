function writeGeneric(hdfName, obj)

    arguments
        hdfName             {mustBeFile}
        obj                 {mustBeA(obj, 'aod.core.Entity')}
    end

    import aod.h5.HDF5
    import aod.core.EntityTypes

    entityType = aod.core.EntityTypes.get(obj);

    persistedProps = getPersistedProperties(obj);
    % Extract out independently set properties
    hasFiles = ismember(persistedProps, "files");
    specialProps = ["Parent", "notes", "UUID", "files"];
    persistedProps = setdiff(persistedProps, specialProps);
    % Extract out container properties
    containers = entityType.containers();
    if ~isempty(containers)
        persistedProps = setdiff(persistedProps, containers);
    end

    % Collect UUIDs of entities within the HDF5 file
    GM = aod.h5.EntityManager(hdfName);
    GM.collect();
    GMT = table(GM);

    % Determine class-specific location
    switch entityType 
        case EntityTypes.EXPERIMENT
            hdfPath = '/Experiment';
            parentPath = [];
        case EntityTypes.SYSTEM
            hdfPath = ['/Experiment/Systems/', char(obj.Name)];
            parentPath = '/Experiment';
        case EntityTypes.CALIBRATION 
            hdfPath = ['/Experiment/Calibrations/', char(obj.label)];
            parentPath = '/Experiment';
        case EntityTypes.CHANNEL 
            doesEntityExist(GMT, obj.Parent);
            parentPath = char(GMT{GMT.UUID == obj.Parent.UUID, 'Path'});
            hdfPath = [parentPath, '/Channels/', char(obj.Name)];
        case EntityTypes.DEVICE
            doesEntityExist(GMT, obj.Parent);
            parentPath = char(GMT{GMT.UUID == obj.Parent.UUID, 'Path'});
            hdfPath = [parentPath, '/Devices/', char(obj.label)];
        case EntityTypes.EPOCH
            hdfPath = ['/Experiment/Epochs', char(obj.label)];
            parentPath = '/Experiment';
        otherwise
            error('Unrecognized entity');
    end

    % Create the new group
    HDF5.createGroup(hdfName, hdfPath);

    % Create default subgroups, if necessary
    if ~isempty(containers)
        HDF5.createGroups(hdfName, hdfPath, containers{:});
        for i = 1:numel(containers)
            HDF5.writeatts(hdfName, [hdfPath, '/', containers{i}], 'Class', 'Container');
        end
    end

    % Write entity identifiers
    HDF5.writeatts(hdfName, hdfPath,...
        'UUID', obj.UUID, 'Class', class(obj), 'EntityType', char(entityType));

    % Write parent link, if necessary
    if ~isempty(parentPath)
        HDF5.createLink(hdfName, parentPath, hdfPath, 'Parent');
    end

    % Write description, if exists
    if ~isempty(obj.description)
        HDF5.writeatts(hdfName, hdfPath, 'Description', obj.description);
    end

    % Write parameters, if necessary
    parameters = entityType.parameters(obj);
    if ~isempty(parameters)
        aod.h5.writeParameters(hdfName, hdfPath, parameters);
    end
    
    % Write file paths, if necessary
    if hasFiles
        h = ancestor(obj, 'aod.core.Experiment');
        HDF5.writeTextDataset(hdfName, hdfPath, 'Files', h.homeDirectory);
        HDF5.writeParameters(hdfName, [hdfPath, '/Files'], obj.files);
    end
    
    % Write remaining properties as datasets
    for i = 1:numel(persistedProps)
        prop = obj.(persistedProps(i));
        if isempty(prop)
            fprintf('Skipping empty property: %s\n', persistedProps(i));
            continue
        end
        % Write links to other entities
        if isSubclass(prop, 'aod.core.Entity')
            isEntityInFile(GMT, prop);
            entityPath = char(GMT{GMT.UUID == prop.UUID, 'Path'});
            HDF5.createLink(hdfName, entityPath, hdfPath, persistedProp(i));
            return
        end
        success = HDF5.writeDataByType(hdfName, hdfPath, persistedProps(i), prop);

        if ~success
            error('Unrecognized property %s of type %s', persistedProps(i), class(persistedProps(i)));
        end
    end
end

function doesEntityExist(GMT, entity)
    if isempty(entity)
        error('Entity does not exist!');
    end
end

function isEntityInFile(GMT, entity)
    if isempty(find(GMT.UUID == entity.UUID)) %#ok<EFIND> 
        error('Entity does not exist in HDF5 file!');
    end
end
